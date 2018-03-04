module Texico
  module CLI
    module Command
      class Base
        attr_reader :prompt, :opts
        
        def initialize(prompt, opts)
          @prompt = prompt
          @opts   = opts
        end

        def run
          prompt.error "I don't know what you mean with '#{opts[:cmd]}'"
        end
        
        def load_config(full = true)
          ConfigFile.load(opts, full).tap do |config|
            unless config
              prompt.say 'I Couldn\'t find a valid config file. Run ' + \
                         prompt.decorate('texico init', :bold, :yellow) + \
                         ' to setup a new project'
              exit
            end
          end
        end
        
        protected

        class << self
          def match?(command)
            true
          end

          def priority
            0
          end

          def inherited(klass)
            (@commands ||= []) << { klass: klass, prio: klass.priority }
          end

          def select(command)
            @commands&.sort_by { |e| -e[:prio] }
                     &.map!    { |e| e[:klass] }
                     &.each    { |k| sk = k.select command; return sk if sk }

            match?(command) && self
          end

          def match(command, *args)
            klass = select(command)
            klass.new(*args) if klass
          end
        end
      end
    end
  end
end
