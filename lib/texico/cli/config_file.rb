require 'yaml'
require 'forwardable'

module Texico
  module CLI
    class ConfigFile
      extend Forwardable
      
      DEFAULT_NAME   = '.texico'
      DEFAULT_CONFIG = {
        name: 'main',
        title: 'Title',
        author: 'Author',
        email: 'author@example.com',
        build: 'build'
      }.freeze
      
      def_delegator :@config, :[]
      
      private
      
      def initialize(config, defaults = {})
        p config
        @config = defaults.merge(config).freeze
      end
      
      class << self
        def exist?(opts)
          File.exist? opts[:config]
        end
        
        def default
          return @default if @default
          @default = DEFAULT_CONFIG.merge read_global
        end
        
        def load(opts)
          return false unless File.exist? opts[:config]
          
          new read_local(opts[:config]), default
        #rescue Errno::ENOENT
          #false
        end
        
        def create(config, opts)
          return if opts[:dry_run]
          File.open opts[:config], 'wb' do |file|
            file.write YAML.dump(config)
          end
        end
        
        private
        
        def read_local(filename)
          yaml = File.open(filename, 'rb') { |f| f.read }
          YAML.load(yaml) || {}
        rescue Errno::ENOENT
          {}
        end
        
        def read_global
          path = File.expand_path(DEFAULT_NAME, ENV['HOME'])
          read_local path
        end
      end
    end
  end
end
