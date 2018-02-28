require 'test_helper'

describe Texico::Parser do
  subject { Texico::Parser.new }
  
  let(:output_normal) { './test/output/missing-begin.txt' }
  
  describe '#feed' do
    it 'accepts lines from a file' do
      File.open(output_normal, 'r') do |file|
        file.each_line do |line|
          subject.feed line.chomp
        end
      end
      
      p subject.root.child(0).errors
    end
  end
end
