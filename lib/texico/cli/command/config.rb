require 'tty-table'

module Texico
  module CLI
    module Command
      class Config < Base
        def run
          config =
            if opts[:global]
              ConfigFile.global
            else
              load_config false
            end.to_hash
          
          did_change = false
          opts[:args].each do |key_value|
            key, value = key_value.split '='
            key = key.to_sym
            did_change = did_change || config[key] != value
            config[key] = value
          end
          
          if did_change
            prompt.say "🌮 Writing new configuration\n", color: :bold
          else
            prompt.say "🌮 Current configuration\n", color: :bold
          end
          
          table = TTY::Table.new \
            header: %w(Option Value).map { |v| prompt.decorate v, :bold },
            rows: config.to_a
          
          prompt.say table.render(:basic) + "\n"
          
          return unless did_change
          
          if opts[:global]
            ConfigFile.store(config, opts, ConfigFile::GLOBAL_CONFIG_PATH)
          else
            ConfigFile.store(config, opts)
          end
        end

        class << self
          def match?(command)
            command == 'config'
          end
        end
      end
    end
  end
end
