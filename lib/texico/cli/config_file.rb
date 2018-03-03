require 'yaml'
require 'forwardable'

module Texico
  module CLI
    class ConfigFile
      extend Forwardable
      
      DEFAULT_NAME       = '.texico'.freeze
      GLOBAL_CONFIG_PATH = File.expand_path(DEFAULT_NAME, ENV['HOME']).freeze
      DEFAULT_CONFIG = {
        name: 'main',
        title: 'Title',
        author: 'Author',
        email: 'author@example.com',
        build: 'build',
        main_filename: 'main.tex'
      }.freeze
      
      def_delegator :@config, :[]
      
      private
      
      def initialize(config, defaults = {})
        @config = defaults.merge(config).freeze
      end
      
      class << self
        def exist?(opts)
          File.exist? opts[:config]
        end
        
        def global
          @global_defaults ||= read_global
        end
        
        def default
          return @default if @default
          @default = DEFAULT_CONFIG.merge global
        end
        
        def load(opts)
          return false unless File.exist? opts[:config]
          new read_local(opts[:config]), default
        end
        
        def store(config, opts, filename = opts[:config])
          return if opts[:dry_run]
          File.open filename, 'wb' do |file|
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
          read_local GLOBAL_CONFIG_PATH
        end
      end
    end
  end
end
