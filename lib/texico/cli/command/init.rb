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
          prompt.say "#{ICON} Creating new project\n", color: :bold
          # Copy the template project
          copy_template config
          # Save the other config options to file
          ConfigFile.store config, target, opts
          # We are done
          prompt.say "#{ICON} Done!", color: :bold
        rescue TTY::Reader::InputInterrupt
          prompt.error 'Aborting'
          exit
        end
        
        private
        
        def target
          File.expand_path('', opts[:args][0] || '.')
        end
        
        def welcome
          if ConfigFile.exist?(opts)
            if opts[:force]
              prompt.warn "#{ICON} Reinitializeing existing project."
            else
              prompt.say "#{ICON} Hey! This project has already been setup " \
                         "with #{opts[:title]}!", color: :bold
              prompt.say '   Use -f to force me to reinitialize it.'
              exit
            end
          else
            prompt.say "#{ICON} I just need a few details", color: :bold
          end
          prompt.say "\n"
        end
        
        def ask_config
          folder_name = File.basename target
          template_choices =
            Hash[Template.list.map { |p| [File.basename(p).capitalize, p] }]
          
          answers =
            prompt.collect do
              key(:name).ask(  'What should be the name of the output PDF?',
                               default: folder_name.downcase.gsub(' ', '-'))
              key(:title).ask( 'What is the title of your document?',
                               default: folder_name.gsub('_', ' ').capitalize)
              key(:author).ask('What is your name?',
                               default: ConfigFile.default[:author])
              key(:email).ask( 'What is your email address?',
                               default: ConfigFile.default[:email])
              key(:template).select("Select a template", template_choices)
            end

          ConfigFile.new answers, ConfigFile::DEFAULT_CONFIG
        end

        def copy_template(config)
          params        = config.to_hash
          template_path = params.delete :template
          template      = Template.load template_path
          
          template_structure =
            template.copy(target, params, opts) do |status|
              file = status.file.basename
              case status.status
              when :successful then prompt.decorate(file, :green)
              when :target_exist then prompt.decorate(file, :red)
              when :replaced_target then prompt.decorate(file, :yellow)
              when :template_error then prompt.decorate(file, :blue)
              end
            end

          tree = TTY::Tree.new template_structure
          prompt.say tree.render + "\n"
          file_copy_legend
        end
        
        def file_copy_legend
          prompt.say \
            format("%s Did copy  %s Replaced existing  %s File existed  %s Template Error\n\n",
                    prompt.decorate("∎", :green),
                    prompt.decorate("∎", :yellow),
                    prompt.decorate("∎", :red)
                    prompt.decorate("∎", :blue)
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
