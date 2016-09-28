require 'texico/version'
require 'texico/compiler'

module Texico
  TIMEOUT = 0.1
  MAXLEN = 0x7FF
  DEFAULT_OPTIONS = {
    halt_on_error: true,
    file_line_error: true,
    output_directory: 'build',
  }
  
  def convert(filename, target: '.')
    compiler = Compiler.new output_directory: target
    compiler.compile filename do |output|
      yield output
    end
    
    # '-interaction=batchmode',
    # ::Open3.popen2e 'pdflatex', '-halt-on-error', '-output-directory', target, filename  do |_, stdout, wait_thr|
    #
    #   loop do
    #     begin
    #       result = stdout.read_nonblock(MAXLEN)
    #       yield result if block_given?
    #     rescue IO::WaitReadable
    #       data_available = IO.select([stdout], nil, nil, TIMEOUT)
    #
    #       unless data_available
    #         wait_thr.kill
    #         break
    #       end
    #       retry
    #
    #     rescue EOFError
    #       break
    #     end
    #   end
    #
    #   wait_thr.value
    # end
  end
  
  module_function :convert
end
