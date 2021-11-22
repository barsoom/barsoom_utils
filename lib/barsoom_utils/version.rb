# frozen_string_literal: true
module BarsoomUtils
  # Use SEMVER in VERSION, build number gets appended on release.
  VERSION = File.read(File.join(__dir__, "../../VERSION"))
end
