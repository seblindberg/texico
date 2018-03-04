require 'fileutils'

module Texico
  module CLI
    module Command
      class Clean < Base
        def run
          config = load_config
          build_dir = config[:build]
          
          if remove(build_dir) || remove(Build::SHADOW_BUILD_DIR)
            prompt.say "#{ICON} Removing old build files", color: :bold
          else
            prompt.say "#{ICON} Everything is already clean", color: :bold
            return
          end
        end
        
        private
        
        def remove(dir)
          return false unless File.exist? dir
          FileUtils.rm_r dir unless opts[:dry_run]
        end

        class << self
          def match?(command)
            command == 'clean'
          end
        end
      end
    end
  end
end
