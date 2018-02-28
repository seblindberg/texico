require 'rooted_tree'

module Texico
  class Parser
    class OutputNode < RootedTree::Node
      attr_accessor :filename, :message
      
      def initialize(filename, message = '')
        super()
        @filename = filename
        @message  = message
      end
      
      def inspect(*args)
        super do |node|
          object_id.to_s(16) +" "+ File.basename(node.filename) + ": " + node.message.inspect
        end
      end
      
      def errors
        result = []
        @message.each_line do |line|
          p line
          case line
          when /\A\s*LaTeX\sWarning\:/
            result << Regexp.last_match.post_match
          when /\.tex:(\d+):\s(.+)\.l.\1/
            result << Regexp.last_match.captures[1]
          end
        end
        
        result
      end
    end
  end
end
