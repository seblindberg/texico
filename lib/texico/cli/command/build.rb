module Texico
  module CLI
    module Command
      class Build < Base
        def run
          config = load_config
          
          prompt.say "#{ICON} Building project", color: :bold
          prompt.say "   Using config #{config.inspect}"
          
          build config
        end
        
        def build(config)
          system "latexmk -pdf -output-directory=#{config[:build]} " \
                         "-latexoption=-interaction=nonstopmode " \
                         "-file-line-error " \
                         "#{config[:main_filename]}"
        end

        class << self
          def match?(command)
            command == 'build' || command.nil?
          end
        end
      end
    end
  end
end
