require 'fileutils'

module Texico
  class Template
    # File
    #
    # The Template File object is an internal object used by the Template class
    # to copy and render template files transparently. It should never be used
    # directly.
    class File
      TEMPLATE_EXTNAME = '.erb'.freeze

      def initialize(relative_path, base_path)
        @relative_path = relative_path.freeze
        @base_path     = base_path.freeze

        freeze
      end

      # Basename
      #
      # Returns the name of the file. In case of template files the .erb
      # extension is removed.
      def basename
        ::File.basename @relative_path, TEMPLATE_EXTNAME
      end

      # Basename
      #
      # Returns the extension of the file. In case of template files the
      # extension of the target file is returned.
      def extname
        ::File.extname basename
      end

      # Dirname
      #
      # Returns the local directory path of the file.
      def dirname
        ::File.dirname @relative_path
      end

      # Returns the filename
      def to_s
        basename
      end

      # Copy
      #
      # Copy the file with its relative path intact to the dest_base_path root.
      #
      # Returns a FileStatus object.
      def copy(params, dest_base_path = '.', opts = {})
        dest_dir  = ::File.expand_path dirname, dest_base_path
        dest_path = ::File.expand_path basename, dest_dir
        force     = false

        if ::File.exist? dest_path
          return FileStatus.new(self, :target_exist) unless opts[:force]
          force = true
        else
          FileUtils.mkdir_p dest_dir unless opts[:dry_run]
        end

        if template?
          err = copy_template src_path, dest_path, params,
                              noop: opts[:dry_run], verbose: opts[:verbose]
          return err if err
        else
          FileUtils.cp src_path, dest_path,
                       noop: opts[:dry_run], verbose: opts[:verbose]
        end

        FileStatus.new(self, force ? :replaced_target : :successful)
      end

      private

      def template?
        ::File.extname(@relative_path) == TEMPLATE_EXTNAME
      end

      def src_path
        ::File.expand_path @relative_path, @base_path
      end

      # Copy Template
      #
      # Returns a status object unless the operation was successful, in which
      # case nil is returned.
      def copy_template(src, dest, params, noop: nil, verbose: nil)
        file_body =
          ::File.open src, 'rb' do |file|
            ERB.new(file.read, 0).result_with_hash params
          end

        return if noop

        ::File.open(dest, 'wb') { |file| file.write file_body }
        nil
      rescue NameError => e
        FileStatus.new self, e
      end
    end
  end
end
