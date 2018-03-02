require 'yaml'
require 'forwardable'

module Texico
  module CLI
    class ConfigFile
      extend Forwardable
      
      def_delegator :@config, :[]
      
      private
      
      def initialize(config)
        @config = config.freeze
      end
      
      class << self
        def exist?(opts)
          File.exist? opts[:config]
        end
        
        def load(opts)
          yaml = File.open(opts[:config], 'rb') { |f| f.read }
          new YAML.load(yaml)
        rescue Errno::ENOENT
          false
        end
        
        def create(config, opts)
          return if opts[:dry_run]
          File.open opts[:config], 'wb' do |file|
            file.write YAML.dump(config)
          end
        end
      end
    end
  end
end
