# coding: utf-8
# frozen_string_literal: true
lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "barsoom_utils/version"

Gem::Specification.new do |spec|
  spec.name          = "barsoom_utils"
  spec.version       = BarsoomUtils::VERSION
  spec.authors       = [ "Tomas Skogberg" ]
  spec.email         = [ "tomas.skogberg@gmail.com" ]
  spec.summary       = %q{Various helpful utils}
  spec.homepage      = "https://dev.auctionet.com/"
  spec.license       = "MIT"
  spec.metadata      = { "rubygems_mfa_required" => "true" }

  spec.files         = `git ls-files -z`.split("\x0")
  spec.require_paths = [ "lib" ]

  # Run time dependencies should not be specified here. You are unlikely to use all of BarsoomUtils in each project, so instead, add the gems that are needed in the project.
end
