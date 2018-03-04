require 'test_helper'
require 'fileutils'

describe Texico::Template do
  subject { Texico::Template }
  let(:target_path)   { File.expand_path '../tmp/target', __FILE__ }
  let(:template_path) { File.expand_path '../template', __FILE__ }
  let(:params)        { { test: 'TEST' } }
  
  let(:template)      { subject.load template_path }
  
  describe '#tree' do
    it 'returns a tree structure' do
      res = template.tree
      assert_equal 'Template', res.keys[0]
      assert res['Template'].include?('file_a.txt')
    end
  end
  
  describe '#copy' do
    before do
      FileUtils.rm_r target_path if File.exist? target_path
    end
    
    it 'copies the template' do
      res = template.copy target_path, params, {}
      assert_equal 'Template', res.keys[0]
    end
  end
end
