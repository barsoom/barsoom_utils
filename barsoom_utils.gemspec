# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'barsoom_utils/version'

Gem::Specification.new do |spec|
  spec.name          = "barsoom_utils"
  spec.version       = BarsoomUtils::VERSION
  spec.authors       = ["Tomas Skogberg"]
  spec.email         = ["tomas.skogberg@gmail.com"]
  spec.summary       = %q{Various helpful utils}
  spec.homepage      = "http://barsoom.se"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"

  spec.add_runtime_dependency "lolcat"
  spec.add_runtime_dependency "attr_extras"
  spec.add_runtime_dependency "redis"
end
