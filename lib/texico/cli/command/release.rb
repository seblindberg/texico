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
            tags = Git.list_tags('.')
            num_tags = tags.length
            count = case num_tags
                    when 0 then 'no releases'
                    when 1 then 'one release'
                    else "#{num_tags} releases"
                    end
            prompt.say "#{ICON} This project currently has #{count}\n",
                       color: :bold

            if num_tags > 0
              prompt.say tags.map { |t| "* #{t}" }.join("\n")
            end

            exit
          end
          
          success = super # Build the project
          
          unless success
            prompt.error "#{ICON} I will only tag the release when it builds " \
                         "without errors."
            exit
          end
          
          Git.tag '.', label, "Releasing #{label}"
        end
        
        private

        def label
          opts[:args][0]
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
