module Texico
  class Result
    def initialize()
      @errors = []
      @successful = true
      @output = []
    end
    
    def fail
      @successful = false
    end
    
    def successful?
      @successful
    end
    
    def set_output(file, pages, bytes)
      @output = [file, pages, bytes]
    end
    
    def add_error(line, message)
      @errors << [line, message]
    end
    
    def each_error
      @errors.each { |e| yield *e }
    end
    
    def output
      @output
    end
  end
end