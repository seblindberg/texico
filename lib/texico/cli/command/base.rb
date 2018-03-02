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
          prompt.error "Unknown command: '#{opts[:cmd]}'"
        end

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
            subclass = @commands&.sort_by { |e| -e[:prio] }
                                &.map!    { |e| e[:klass] }
                                &.find    { |klass| klass.match? command }

            subclass || (match?(command) && self)
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
