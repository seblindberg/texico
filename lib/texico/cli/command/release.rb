module Texico
  module CLI
    module Command
      class Release < Build
        def run
          super # Build the project
          
          tag
        end
        
        private
        
        def tag
          p 'git tag'
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
