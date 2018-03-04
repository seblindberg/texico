module Texico
  module CLI
    module Command
      class Release < Build
        GIT_DIR = File.expand_path('.git').freeze
        
        def run
          unless File.exist? GIT_DIR
            prompt.error "#{ICON} You don't seem to be using git."
            exit
          end
          
          unless label
            prompt.error "#{ICON} You have to give me a tag label."
            exit
          end
          
          success = super # Build the project
          
          unless success
            prompt.error "#{ICON} I will only tag the release when it builds " \
                         "without errors."
            exit
          end
          
          tag
        end
        
        private
        
        def label
          opts[:args][0]
        end
        
        def tag
          system "git tag -a #{label} -m 'Releasing #{label}'"
        end
        
        class << self
          def match?(command)
            command == 'release'
          end
        end
      end
    end
  end
end
