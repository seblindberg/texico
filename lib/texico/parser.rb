# Parser for the messy data spit out pdflatex. The parser expects complete
# lines, output by pdflatex, without any trailing newline charachters.
#

module Texico
  class Parser
    attr_reader :root
    
    def initialize
      @counter = 0
      @state   = :message
      @root    = OutputNode.new ''
      @node    = @root
    end
    
    # Given a complete line, as printed by pdflatex, this method will do the
    # rest. This involvs interpreting the line given the current state of the
    # parse. The state depends on the lines that have come before, so the order
    # in which new lines are fed is important.
    
    def feed(line)
      case line
      when ''
        case @state
        when :filename then @state = :message
        when :message then @node.message += "\n" unless @node.message[-1] == "\n"
        end
        
      when /\A\s*\(/
        @counter += 1
        child = OutputNode.new Regexp.last_match.post_match.chomp
        @node << child
        @node  = child
        @state = :filename
        
      when /\A\s*(\)+)/
        closing_brackets = $1.length
        @counter -= closing_brackets
        
        closing_brackets.times do
          @node = @node.parent
        end
  
        @node.message += Regexp.last_match.post_match.chomp
  
        @state = :message
      else
        if @state == :filename
          @node.filename += line.chomp
        elsif @state == :message
          # Args
          @node.message += line.chomp
        end
      end
    end
  end
end
