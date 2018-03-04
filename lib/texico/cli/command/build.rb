module Texico
  module CLI
    module Command
      class Build < Base
        SHADOW_BUILD_DIR = '.build'.freeze
        
        def run
          config = load_config
          
          prompt.say "#{ICON} Building project", color: :bold
          
          build config
        end
        
        def build(config)
          compiler = Compiler.new output_directory: SHADOW_BUILD_DIR
          build_result = compiler.compile config[:main_file]
          
          return false unless build_result
          copy_build build_result[:file], config
          true
        end
        
        private
        
        def copy_build(build_file, config)
          dest = File.expand_path(config[:name] + '.pdf', config[:build])
          
          FileUtils.mkdir config[:build] unless File.exist? config[:build]
          FileUtils.mv build_file, dest
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
