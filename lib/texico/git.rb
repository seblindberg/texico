require 'open3'

module Texico
  module Git
    module_function
    def init(target, initial_commit = false)
      if initial_commit
        system "git init '#{target}' && git -C '#{target}' add . " \
               "&& git -C '#{target}' commit -m 'Initial commit'"
      else
        system "git init '#{target}'"
      end
    end

    module_function
    def tag(target, label, message)
      system "git -C '#{target}' tag -a #{label} -m '#{message}'"
    end
    
    module_function
    def list_tags(target)
      Open3.popen2 "git -C '#{target}' tag -l" do |_, stdout, _|
        stdout.each_line.map { |line| line.chomp }
      end
    end
  end
end
