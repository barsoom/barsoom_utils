# coding: utf-8
# frozen_string_literal: true
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "barsoom_utils/version"

Gem::Specification.new do |spec|
  spec.name          = "barsoom_utils"
  spec.version       = BarsoomUtils::VERSION
  spec.authors       = [ "Tomas Skogberg" ]
  spec.email         = [ "tomas.skogberg@gmail.com" ]
  spec.summary       = %q{Various helpful utils}
  spec.homepage      = "http://barsoom.se"
  spec.license       = "MIT"
  spec.metadata      = { "rubygems_mfa_required" => "true" }

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = [ "lib" ]

  spec.add_development_dependency "bundler", ">= 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "httparty"
  spec.add_development_dependency "lolcat"
  spec.add_development_dependency "attr_extras"
  spec.add_development_dependency "redis"
  spec.add_development_dependency "honeybadger"
  spec.add_development_dependency "fixme"
  spec.add_development_dependency "rubocop"

  # Run time dependencies should not be specified here. You are unlikely to use all of BarsoomUtils in each project, so instead, add the gems that are needed in the project.
end
