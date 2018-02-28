require 'open3'

module Texico
  class Compiler
    TIMEOUT = 0.5
    MAXLEN = 0x7FF
    
    DEFAULT_OPTIONS = {
      halt_on_error: true,
      file_line_error: true,
      output_directory: 'build'
    }
    
    ERROR_PATTERN = /\.tex\:(?<line>\d+)\:\s*(?<message>.+)\n/
    LATEX_PATTERN = /^! LaTeX Error: (?<message>.+)$/i
    WARNING_PATTERN = /^LaTeX Warning: (?<message>.+)$/i
    
    OUTPUT_PATTERN = /output\swritten\son\s"
                     (?<file>[^"]+)"\s
                     \(
                       (?<pages>\d+)\spages,\s
                       (?<bytes>\d+)\sbytes
                     \)/ix
    
    def initialize(**options)
      @options = DEFAULT_OPTIONS.merge options
    end
    
    def compile(file)
      # Transform the arguments
      args = @options.map { |k, v| transform_option k, v }.flatten
      
      # stream = StringIO.new
      result = Result.new
      parser = Parser.new
      feeder = LineFeeder.new { |line| parser.feed parser }
      
      # Open the process in a separate thread and monitor
      # it, along with stdin and stdout
      ::Open3.popen2e 'pdflatex', *args, file do |_, stdout, thread|
        loop do
          begin
            partial = stdout.read_nonblock MAXLEN
            
            feeder.feed partial
            
            # stream.puts partial
            # puts partial
          rescue IO::WaitReadable
            unless IO.select([stdout], nil, nil, TIMEOUT)
              thread.kill
              break
            end
            
            retry
            
          rescue EOFError
            # puts 'EOFError'
            break
          end
        end
        
        feeder.terminate
        
        # stream.rewind
        
        if thread.alive?
          puts "Thread still alive"
          thread.kill
          result.fail
          # stream.each_line do |line|
          #   line.match LATEX_PATTERN do |m|
          #     result.add_error 0, m[:message]
          #     break
          #   end
          # end
        
        elsif thread.value.success?
          # stream.each_line do |line|
          #   line.match OUTPUT_PATTERN do |m|
          #     result.set_output m[:file], m[:pages].to_i, m[:bytes].to_i
          #     break
          #   end
          # end
        else
          result.fail
          # stream.each_line do |line|
          #   line.match ERROR_PATTERN do |m|
          #     result.add_error m[:line].to_i, m[:message]
          #   end
          # end
        end
      end
      
      result
    end
    
    # Takes a symbol (or string) one the form :some_option and transforms it
    # into the string "-some-option". If the value is
    # a) false, the output string will be empty.
    # b) true, only the key will be returned.
    # c) some other value, an array with the transformed key and the value is
    #    returned.
    private def transform_option(key, value)
      # Skip the option if the value is nil or false
      return '' unless value
      # Transform the key into a format that is accepted by pdflatex
      option = '-' + key.to_s.gsub('_', '-')
      
      value.equal?(true) ? option : [option, value]
    end
  end
end
