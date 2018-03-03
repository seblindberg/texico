module Texico
  module CLI
    module Command
      class Build < Base
        def run
          config = load_config
          
          unless config
            prompt.say 'I Couldn\'t find a valid config file. Run ' + \
                       prompt.decorate('texico init', :bold, :yellow) + \
                       ' to setup a new project'
            exit
          end
          
          prompt.say '🌮 Building project', color: :bold
          prompt.say "   Using config #{config.inspect}"
        end

        def load_config
          ConfigFile.load opts
        end

        class << self
          def match?(command)
            command == 'build' || command.nil?
          end
        end
      end
    end
  end
end
