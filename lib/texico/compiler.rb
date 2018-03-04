require 'open3'

module Texico
  class Compiler
    COMMAND = 'latexmk'
    
    LATEXMK_OPTIONS = {
      pdf:              true,
      output_directory: '.build',
      latexoption: {
        interaction:    'nonstopmode',
        file_line_error: true
      }.freeze
    }.freeze
    
    OUTPUT_PATTERN =
      %r{\AOutput written on ([^\s]+) \((\d+) page, (\d+) bytes\)}
    
    def initialize(**options)
      @args = LATEXMK_OPTIONS
                .merge(options)
                .map { |k, v| transform_option(k, v) }.join ' '
    end
    
    def compile(file)
      # TODO: This looks very hacky...
      build_result = false
      Open3.popen2("#{COMMAND} #@args #{file}") do |_, stdout, _|
        stdout.each_line do |line|
          if m = line.match(OUTPUT_PATTERN)
            build_result = { file: m[1], pages: m[2], bytes: m[3] }
            break
          end
        end
      end
      build_result
    end
    
    # Takes a symbol (or string) one the form :some_option and transforms it
    # into the string "-some-option". If the value is
    # a) false, the output string will be empty.
    # b) true, only the key will be returned.
    # c) some other value, an array with the transformed key and the value is
    #    returned.
    private def transform_option(key, value)
      # Skip the option if the value is nil or false
      return '' unless value
      # Transform the key into a format that is accepted by pdflatex
      option = '-' + key.to_s.gsub('_', '-')
      
      case value
      when TrueClass then return option
      when Hash
        value.map { |k, v| "#{option}=#{transform_option k, v }" }.join ' '
      else
        "#{option}=#{value}"
      end
    end
  end
end
