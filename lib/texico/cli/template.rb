require 'erb'
require 'fileutils'

module Texico
  module CLI
    class Template
      BASE_PATH = File.expand_path('../../../../templates', __FILE__)
      
      def copy(config, opts)
        entries = @entries.dup

        # Find the main file
        main_entry = @entries.find { |(f, _)| f == 'main.erb' }
        
        # Copy each entry
        @entries.each do |entry|
          next if entry == main_entry
          if opts[:dry_run]
            
          else
            self.class.copy_file entry[1], entry[0], opts
          end
        end
        
        return if opts[:dry_run]
        
        main_file_body =
          File.open main_entry[1], 'rb' do |main_file|
            erb_template = ERB.new main_file.read, 0
            erb_template.result_with_hash config
          end
        
        main_target = main_entry[0].sub(/erb\z/, 'tex')
        
        return false if File.exist?(main_target) && !opts[:force]
        
        File.open main_target, 'wb' do |main_file|
          main_file.write main_file_body
        end
      end
      
      private

      def initialize(entries)
        @entries = entries.freeze
      end

      class << self
        def list
          Dir.glob "#{BASE_PATH}/*"
        end
        
        def exist?(template)
          File.exist? template
        end
        
        def copy_file(src, dest, opts)
          FileUtils.cp_r src, dest, remove_destination: opts[:force]
        end

        def load(template)
          # Load all the files in the template folder
          entries = Dir.entries(template).reject { |f| ['.', '..'].include? f }
                       .map { |e| [e, File.expand_path(e, template)] }
          
          new entries
          #ERB.new File.open(template, 'rb') { |f| f.read }
          #new YAML.load(yaml)
        rescue Errno::ENOENT
          false
        end
      end
    end
  end
end
