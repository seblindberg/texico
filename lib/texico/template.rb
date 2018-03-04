require 'erb'
require 'fileutils'
# require 'tty-tree'

module Texico
  class Template
    BASE_PATH = ::File.expand_path('../../../templates', __FILE__)
    
    # Returns a report of what files where copied.
    def copy(config, opts)
      # Extract main file
      file_tree = @file_tree.dup
      # TODO: raise something if the main file does not exist
      main_file   = file_tree.delete 'main.erb'
      main_target = main_file.sub(/erb\z/, 'tex')
      main_target_exist = ::File.exist?(main_target)

      # 1. Render the main file
      unless opts[:dry_run] || (!opts[:force] && main_target_exist)
        main_file_path = ::File.expand_path main_file, @base_path
        main_file_body =
          ::File.open main_file_path, 'rb' do |file|
            erb_template = ERB.new file.read, 0
            erb_template.result_with_hash config
          end

        ::File.open main_target, 'wb' do |file|
          file.write main_file_body
        end
      end

      # 2. Create directory structure
      self.class.each_tree_dir file_tree do |path|
        self.class.mkdir path, opts
      end

      # 3. Copy files from tree
      #    TODO: sort the tree
      self.class.map_tree_leaf file_tree do |name, local_path|
        # Copy file
        src_path = ::File.expand_path local_path, @base_path
        dest_exist = ::File.exist? local_path
        
        self.class.copy src_path, local_path, opts
        # Give a chance to render the file
        yield name, dest_exist if block_given?
      end.push(yield main_target, main_target_exist)
    end
    
    private

    def initialize(base_path, file_tree)
      @base_path = base_path
      @file_tree = file_tree
    end

    class << self
      def list
        Dir.glob "#{BASE_PATH}/*"
      end
      
      def exist?(template)
        ::File.exist? template
      end
      
      def load_file_tree(root, dir = '')
        base_path = ::File.expand_path dir, root
        Dir.entries(base_path)
          .reject { |e| ['.', '..'].include? e }
          .map do |e|
            local_path = (dir + e).freeze
            full_path = ::File.expand_path local_path, root
            if ::File.file?(full_path)
              File.new local_path, root
            else
              { e => load_file_tree(root, local_path + '/') }.freeze
            end
          end.freeze
      end
      
      def each_tree_dir(tree, root = '', &block)
        tree.each do |node|
          next if node.is_a? String
          dir = node.keys[0]
          path = "#{root}#{dir}/"
          yield path
          each_tree_dir node[dir], path, &block
        end
      end
      
      def map_tree_leaf(tree, root = '', &block)
        tree.map do |node|
          if node.is_a? String
            yield node, "#{root}#{node}"
          else
            dir = node.keys[0]
            {
              dir => map_tree_leaf(node[dir],
                                   "#{root}#{dir}/",
                                   &block)
            }
          end
        end
      end
      
      def mkdir(path, opts)
        FileUtils.mkdir_p path unless opts[:dry_run]
      end
      
      def copy(src, dest, opts)
        return if opts[:dry_run] || (!opts[:force] && ::File.exist?(dest))
        FileUtils.cp src, dest
      end

      def load(template)
        file_tree = load_file_tree template
        new template.freeze, file_tree
      rescue Errno::ENOENT
        false
      end
    end
  end
end
