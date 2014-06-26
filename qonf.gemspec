# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'qonf/version'

Gem::Specification.new do |spec|
  spec.name          = "qonf"
  spec.version       = Qonf::VERSION
  spec.authors       = ["Geoff Hayes"]
  spec.email         = ["hayesgm@gmail.com"]
  spec.description   = %q{Qonf is a simple configuration management tool}
  spec.summary       = %q{Simplest use case, add config/qonf.json or config/qonf.yaml and call Qonf.key to pull key from config file.  And much more.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
