# This class accepts chunks of input and returns whole lines, either as they
# become avaliable or uppon request.

module Texico
  class LineFeeder
    def initialize(&default_block)
      @buffer = StringIO.new
      @default_block = default_block
    end
    
    # Give the LineFeeder a partial containing 0 or more lines and it will
    # append it to what is already stored internally. If a block is given, each
    # complete line currently held will be yielded to it and subsequently
    # removed.
    
    def feed(partial, &block)
      # Append the partial to the end of the buffer
      @buffer.write partial
      
      # Return if there is no current interest in
      # retreiving lines
      return each_line(&block) if block_given?
      each_line(&@default_block) if @default_block
    end
    
    def terminated?
      raise 'Internal buffer in inconsistent state' unless @buffer.eof?
      
      @buffer.seek(-1, IO::SEEK_CUR)
      @buffer.getc == "\n"
    end
    
    def terminate(&block)
      @buffer.puts unless terminated?
      return each_line(&block) if block_given?
      each_line(&@default_block) if @default_block
    end
    
    # Consume each whole line that has been stored in the buffer.
    #
    def each_line
      @buffer.rewind
      
      remainder =
        until @buffer.eof?
          line = @buffer.gets
          
          # Make sure we read a complete, terminated line
          break line unless line[-1] == "\n"
          yield line.chomp
          nil
        end

      # Clear the buffer and put back the remainder
      @buffer = StringIO.new
      @buffer.write remainder if remainder
    end
  end
end