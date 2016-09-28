require 'open3'

module Texico
  class Compiler
    TIMEOUT = 0.5
    MAXLEN = 0x7FF
    DEFAULT_OPTIONS = {
      halt_on_error: true,
      file_line_error: true,
      output_directory: 'build',
    }
    
    def initialize(**options)
      @options = DEFAULT_OPTIONS.merge options
    end
    
    def compile(file)
      args = @options.map { |k, v| transform_option k, v }
      
      ::Open3.popen2e 'pdflatex', *args, file do |_, stdout, thread|
        loop do
          begin
            output = stdout.read_nonblock(MAXLEN)
            yield output if block_given?
            
          rescue IO::WaitReadable
            unless IO.select([stdout], nil, nil, TIMEOUT)
              thread.kill
              break
            end
            
            retry
            
          rescue EOFError
            break
          end
        end
        
        p wait_thr.value
      end
    end
    
    private def transform_option(key, value)
      # Skip the option if the value is nil or false
      return '' unless value
      
      option = '-' + key.to_s.gsub('_', '-')
      
      if value.equal? true
        option
      else
        option + ' ' + value
      end
    end
  end
end