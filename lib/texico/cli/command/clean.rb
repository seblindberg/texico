require 'fileutils'

module Texico
  module CLI
    module Command
      class Clean < Base
        def run
          config = load_config
          
          build_dir = config[:build]
          
          if File.exist? build_dir
            prompt.say "#{ICON} Removing #{build_dir}", color: :bold
          else
            prompt.say "#{ICON} Everything is already clean", color: :bold
            return
          end
          
          FileUtils.rm_r build_dir unless opts[:dry_run]
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
