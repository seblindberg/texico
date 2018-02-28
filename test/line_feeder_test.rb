require 'test_helper'

describe Texico::LineFeeder do
  let(:klass) { Texico::LineFeeder }
  subject { klass.new }

  let(:partial_a) { "1\n2" }
  let(:partial_b) { "\n3" }
  let(:lines) { [] }

  describe '#initialize' do
    it 'accepts a default handler' do
      lf = klass.new { |line| lines << line }
      lf.feed partial_a
      assert_equal ['1'], lines
      lf.terminate
      assert_equal ['1', '2'], lines
    end
  end

  describe '#feed' do
    it 'accepts a string' do
      subject.feed partial_a
    end
    
    it 'accepts a block and yields lines to it' do
      subject.feed(partial_a) { |line| lines << line }
      assert_equal ['1'], lines
    end
    
    it 'remembers previously unconsumed lines' do
      subject.feed(partial_a) { |line| lines << line }
      subject.feed(partial_b) { |line| lines << line }
      
      assert_equal ['1', '2'], lines
    end
  end
  
  describe '#each_line' do
    before { subject.feed(partial_a) }

    it 'iterates over all complete lines' do
      subject.each_line { |line| lines << line }
      assert_equal ['1'], lines
    end
  end
  
  describe '#terminated?' do
    before { subject.feed(partial_a) }
    it 'returns false when the last char is not a newline' do
      refute subject.terminated?
    end
    
    it 'returns true when the last char is a newline' do
      subject.feed "\n"
      assert subject.terminated?
    end
  end
  
  describe '#terminate' do
    before { subject.feed(partial_a) }
    
    it 'appends a newline character to the buffer' do
      subject.terminate
      assert subject.terminated?
    end
    
    it 'does nothing if the buffer is already terminated' do
      subject.feed "\n"
      subject.terminate
      
      subject.each_line { |line| lines << line }
      assert_equal 2, lines.count
    end
    
    it 'iterates over the lines if given a block' do
      subject.terminate { |line| lines << line }
      assert_equal ['1', '2'], lines
    end
  end
end
