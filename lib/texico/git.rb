module Texico
  module Git
    module_function
    def init(target, initial_commit = false)
      if initial_commit
        system "git init '#{target}' && cd '#{target}' && git add . " \
               "&& git commit -m 'Initial commit'"
      else
        system "git init '#{target}'"
      end
    end
  end
end
