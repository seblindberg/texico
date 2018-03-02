module Texico
  module CLI
    module Command
      class Init < Base
        def run
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
          
          folder_name = File.basename Dir.pwd
          template_choices =
            Hash[Template.list.map { |p| [File.basename(p).capitalize, p] }]
          
          prompt.say "\n"
          config =
            prompt.collect do
              key(:name).ask('What should be the name of the output PDF?',
                             default: folder_name)
              
              key(:title).ask('What is the title of your document?',
                              default: 'Template Paper')
                              
              key(:author).ask('Who is the author?',
                                default: 'Template Author')
              
              key(:template).select("Select a template", template_choices)
            end
          
          prompt.say '🌮 Creating new project', color: :bold
                    
          template = Template.load config.delete(:template)
          template.copy(config, opts) do |src, _, did_copy|
            if did_copy
              prompt.say "Copying #{File.basename src}"
            else
              prompt.say "Would copy #{File.basename src}"
            end
          end
          
          ConfigFile.create config, opts
          
        rescue TTY::Reader::InputInterrupt
          prompt.error 'Aborting'
          exit
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
