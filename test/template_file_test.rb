require 'test_helper'
require 'fileutils'

describe Texico::Template::File do
  subject { Texico::Template::File }
  
  let(:target_path)   { File.expand_path '../tmp/target', __FILE__ }
  let(:template_path) { File.expand_path '../template', __FILE__ }
  let(:file_a_path)   { 'file_a.txt.erb' }
  let(:file_b_path)   { 'subdir/file_b.txt' }
  let(:file_c_path)   { 'file_c.txt.erb' }
  let(:file_a)        { subject.new file_a_path, template_path }
  let(:file_b)        { subject.new file_b_path, template_path }
  let(:file_c)        { subject.new file_c_path, template_path }
  let(:params)        { { test: 'TEST' } }
  
  describe '#basename' do
    it 'returns the name of the file' do
      assert_equal 'file_b.txt', file_b.basename
    end
    
    it 'does not include .erb in the filename' do
      assert_equal 'file_a.txt', file_a.basename
    end
  end
  
  describe '#extname' do
    it 'returns the file extension' do
      assert_equal '.txt', file_b.extname
    end
    
    it 'does not return the .erb extension' do
      assert_equal '.txt', file_a.extname
    end
  end
  
  describe '#dirname' do
    it 'returns the file directory' do
      assert_equal '.', file_a.dirname
      assert_equal 'subdir', file_b.dirname
    end
  end
  
  describe '#copy' do
    before do
      FileUtils.rm_r target_path if File.exist? target_path
    end
    
    it 'copies regular files' do
      file_b.copy params, target_path
      file_b_target_path = File.expand_path file_b_path, target_path
      assert File.exist?(file_b_target_path)
      assert_equal 'FILE B',
                   File.open(file_b_target_path, 'r') { |f| f.read }
    end
    
    it 'copies template files' do
      file_a.copy params, target_path
      file_a_target_path = File.expand_path file_a.basename, target_path
      assert File.exist?(file_a_target_path)
      assert_equal 'FILE A:TEST',
                   File.open(file_a_target_path, 'r') { |f| f.read }
    end
    
    it 'handles broken templates' do
      res = file_c.copy params, target_path
      assert_equal :template_error, res.status
    end
    
    it 'returns a status object' do
      res = file_b.copy params, target_path

      assert_equal :successful, res.status
      assert_equal file_b, res.file
    end
    
    #
    # Status from regular files
    #
    
    it 'does not replace regular files' do
      file_b.copy params, target_path       # Copy once
      res = file_b.copy params, target_path # Copy twice
      
      assert_equal :target_exist, res.status
    end
    
    it 'replaces regular files when forced' do
      file_b.copy params, target_path
      res = file_b.copy params, target_path, { force: true }
      
      assert_equal :replaced_target, res.status
    end
    
    #
    # Status from template files
    #
    
    it 'does not replace template files' do
      file_a.copy params, target_path       # Copy once
      res = file_a.copy params, target_path # Copy twice
      
      assert_equal :target_exist, res.status
    end
    
    it 'replaces template files when forced' do
      file_a.copy params, target_path
      res = file_a.copy params, target_path, { force: true }
      
      assert_equal :replaced_target, res.status
    end
  end
end