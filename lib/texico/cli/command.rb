module Texico
  module CLI
    module Command
      extend self
 
      def match(*args)
        Base.match(*args)
      end
    end
  end
end
