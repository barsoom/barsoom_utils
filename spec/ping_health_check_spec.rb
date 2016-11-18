require "spec_helper"
require "barsoom_utils/ping_health_check"

describe BarsoomUtils::PingHealthCheck, ".call" do
  before do
    ENV["ENABLE_HEALTH_CHECKS"] = "true"
  end

  after do
    ENV["ENABLE_HEALTH_CHECKS"] = nil
  end

  it "works" do
    expect(HTTParty).to receive(:get).with("https://hchk.io/foo").and_return(double(:response, code: 200))
    BarsoomUtils::PingHealthCheck.call("foo")
  end

  it "silently reports an error to devs if it fails with a bad response code" do
    expect(HTTParty).to receive(:get).with("https://hchk.io/foo").and_return(double(:response, code: 404))
    expect(BarsoomUtils::ExceptionNotifier).to receive(:message).with(anything, /foo/)
    BarsoomUtils::PingHealthCheck.call("foo")
  end

  it "silently reports an error to devs if it fails with an exception" do
    expect(HTTParty).to receive(:get).with("https://hchk.io/foo").and_raise("fail")
    expect(BarsoomUtils::ExceptionNotifier).to receive(:message).with(anything, /foo/)
    BarsoomUtils::PingHealthCheck.call("foo")
  end
end
