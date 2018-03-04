# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'texico/version'

Gem::Specification.new do |spec|
  spec.name          = "texico"
  spec.version       = Texico::VERSION
  spec.authors       = ["Sebastian Lindberg"]
  spec.email         = ["seb.lindberg@gmail.com"]

  spec.summary       = "Command line utility for managing Latex projects."
  spec.description   = "Utility for handling project templates, build " \
                       "settings and project management"
  spec.homepage      = "https://github.com/seblindberg/texico"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "slop", "~> 4.6"
  spec.add_dependency "tty-prompt", "~> 0.15"
  spec.add_dependency "tty-tree", "~> 0.1"
  spec.add_dependency "tty-table", "~> 0.10"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
