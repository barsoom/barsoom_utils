require "bundler/setup"
Bundler.setup

require "barsoom_utils"

RSpec.configure do |config|
  config.order = "random"
end
