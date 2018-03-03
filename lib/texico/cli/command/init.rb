require 'tty-tree'

module Texico
  module CLI
    module Command
      class Init < Base
        def run
          # Show welcome text
          welcome
          # As for configuration options for this session
          config = ask_config
          # Indicate that the config was accepted
          prompt.say "🌮 Creating new project\n", color: :bold
          # Copy the template project
          copy_template config.delete(:template), config
          # Save the other config options to file
          ConfigFile.create config, opts
          # We are done
          prompt.say "🌮 Done!", color: :bold
        rescue TTY::Reader::InputInterrupt
          prompt.error 'Aborting'
          exit
        end
        
        private
        
        def welcome
          if ConfigFile.exist?(opts)
            if opts[:force]
              prompt.warn '🌮 Reinitializeing existing project.'
            else
              prompt.say '🌮 Hey! This project has already been setup with ' \
                         "#{opts[:title]}!", color: :bold
              prompt.say '   Use -f to force me to reinitialize it.'
              exit
            end
          else
            prompt.say '🌮 I just need a few details', color: :bold
          end
          prompt.say "\n"
        end
        
        def ask_config
          folder_name = File.basename Dir.pwd
          template_choices =
            Hash[Template.list.map { |p| [File.basename(p).capitalize, p] }]
            
          prompt.collect do
            key(:name).ask(  'What should be the name of the output PDF?',
                             default: folder_name.downcase.gsub(' ', '-'))
            key(:title).ask( 'What is the title of your document?',
                             default: folder_name)
            key(:author).ask('What is your name?',
                             default: ConfigFile.default[:author])
            key(:email).ask( 'What is your email address?',
                             default: ConfigFile.default[:email])
            key(:template).select("Select a template", template_choices)
          end
        end
        
        def copy_template(template_path, config)
          template_name = File.basename(template_path).capitalize
          template = Template.load template_path
          template_structure =
            template.copy(config, opts) do |file, exist|
              if exist && opts[:force]
                prompt.decorate(file, :yellow)
              elsif exist
                prompt.decorate(file, :red)
              elsif opts[:dry_run]
                file
              else
                prompt.decorate(file, :green)
              end
            end

          tree = TTY::Tree.new({ template_name => template_structure })
          prompt.say tree.render + "\n"
          file_copy_legend
        end
        
        def file_copy_legend
          prompt.say \
            format("%s Did copy  %s Replaced existing  %s File existed\n\n",
                    prompt.decorate("∎", :green),
                    prompt.decorate("∎", :yellow),
                    prompt.decorate("∎", :red)
                  )
        end

        class << self
          def match?(command)
            command == 'init'
          end
        end
      end
    end
  end
end
