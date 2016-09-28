module Texico
  class Result
    def initialize()
      @errors = []
      @successful = true
    end
    
    def fail
      @successful = false
    end
    
    def successful?
      @successful
    end
    
    def add_error(line, message)
      @errors << [line, message]
    end
    
    def each_error
      @errors.each { |e| yield *e }
    end
  end
end