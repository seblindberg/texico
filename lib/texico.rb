require 'texico/version'
require 'texico/result'
require 'texico/line_feeder'
require 'texico/parser'
require 'texico/parser/output_node'
require 'texico/compiler'

module Texico

  def convert(filename, target: 'build')
    compiler = Compiler.new output_directory: target
    compiler.compile filename do |output|
      yield output
    end
  end
  
  module_function :convert
end
