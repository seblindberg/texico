module Texico
  module CLI
    module Command
      class Config < Base
        def run
          config =
            if opts[:global]
              load_global
            else
              load_local.tap do |config|
                unless config
                  prompt.say 'I Couldn\'t find a valid config file. Run ' + \
                             prompt.decorate('texico init', :bold, :yellow) + \
                             ' to setup a new project'
                  exit
                end
              end
            end
          
          opts[:args].each do |key_value|
            key, value = key_value.split '='
            config[key.to_sym] = value
          end
          
          if opts[:global]
            ConfigFile.store(config, opts, ConfigFile::GLOBAL_CONFIG_PATH)
          else
            ConfigFile.store(config, opts)
          end
        end

        def load_local
          ConfigFile.load opts
        end
        
        def load_global
          ConfigFile.global
        end

        class << self
          def match?(command)
            command == 'config' || command.nil?
          end
        end
      end
    end
  end
end
