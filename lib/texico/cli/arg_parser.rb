require 'slop'
require 'tty-prompt'

module Texico
  module CLI
    class ArgParser
      # Returns a hash with the options
      #
      # The method may call Kernel.exit
      def parse(items = ARGV, prompt: TTY::Prompt.new)
        title = prompt.decorate('texico', :yellow)
        opts =
          Slop.parse(items) do |o|
            o.banner = "#{title} [options] ..."

            o.bool '-v', '--verbose', 'enable verbose mode'
            o.bool '-q', '--quiet', 'suppress output (quiet mode)'
            o.bool '-h', '--help', 'Display this help'
            o.bool '-f', '--force', "Force #{title} to act"
            o.bool '-d', '--dry-run', 'Only show what files would be copied'

            o.string '-c', '--config', 'Config file to use',
                     default: ConfigFile::DEFAULT_NAME

            o.on '--version', 'print the version' do
              puts VERSION
              exit
            end

            o.separator ""
            o.separator "#{title} [options] init"
            o.separator "    Initializes a new 🌮 project in the current directory."
          end
          
        if opts[:help]
          puts opts
          exit
        end

        command = opts.arguments[0]

        Command.match command,
                      prompt,
                      { cmd: command,
                        args: opts.arguments[1..-1],
                        title: title,
                        **opts.to_hash }
      end
    end
  end
end
