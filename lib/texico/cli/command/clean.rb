require 'fileutils'

module Texico
  module CLI
    module Command
      class Clean < Base
        def run
          config = load_config
          
          build_dir = config[:build_dir]
          prompt.say "#{ICON} Removing #{build_dir}", color: :bold
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
