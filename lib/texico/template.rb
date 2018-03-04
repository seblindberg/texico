require 'erb'
require 'fileutils'

module Texico
  # Template
  #
  # Class for handling Texico templates. A template is really just a folder with
  # some files in it. The template object handles moving those files, as well as
  # rendering any .erb files.
  class Template
    BASE_PATH = ::File.expand_path('../../../templates', __FILE__)

    attr_reader :name

    # Tree
    #
    # Returns the template structure in a format compatible with tty-tree.
    def tree
      { name => self.class.map_tree(@file_tree, &:to_s) }
    end

    # Returns a report of what files where copied.
    def copy(dest, params, opts, &block)
      map_status = block_given? ? block : ->(status) { status.to_s }
      status_tree =
        self.class.map_tree(@file_tree) do |file|
          map_status.call(file.copy(params, dest, opts))
        end
      { name => status_tree }
    end

    private

    def initialize(name, file_tree)
      @name      = name.freeze
      @file_tree = file_tree

      freeze
    end

    class << self
      # List
      #
      # List available templates
      def list
        Dir.glob "#{BASE_PATH}/*"
      end

      def exist?(_)
        raise RuntimeError
        #::File.exist? template
      end

      def load_file_tree(root, current_dir = '')
        base_path = ::File.expand_path current_dir, root
        Dir.entries(base_path)
           .reject { |entry| ['.', '..'].include? entry }
           .map do |entry|
             local_path = (current_dir + entry).freeze
             full_path  = ::File.expand_path local_path, root

             if ::File.file?(full_path)
               File.new local_path, root
             else
               { entry.freeze => load_file_tree(root, local_path + '/') }.freeze
             end
           end.freeze
      end

      def map_tree(tree, root = '', &block)
        tree.map do |node|
          if node.is_a? Hash
            dir = node.keys[0]
            { dir => map_tree(node[dir], "#{root}#{dir}/", &block) }
          else
            yield node
          end
        end
      end

      def load(template)
        file_tree     = load_file_tree template
        template_name = ::File.basename(template).capitalize

        new template_name, file_tree
      rescue Errno::ENOENT
        false
      end
    end
  end
end
