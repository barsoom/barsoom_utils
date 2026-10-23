# frozen_string_literal: true
require "rubocop"
require "rubocop/rspec/support"
require "barsoom_utils/rubocop"

RSpec.configure do |config|
  config.include RuboCop::RSpec::ExpectOffense
end
