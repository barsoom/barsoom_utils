# frozen_string_literal: true
require "barsoom_utils/ping_health_check"

RSpec.describe BarsoomUtils::PingHealthCheck, ".call" do
  around do |example|
    ENV["ENABLE_HEALTH_CHECKS"] = "true"
    example.run
    ENV["ENABLE_HEALTH_CHECKS"] = nil
  end

  it "does nothing on a 200 OK response" do
    expect(HTTParty).to receive(:get).with("https://hc-ping.com/foo").and_return(double(:response, code: 200, headers: {}))

    BarsoomUtils::PingHealthCheck.call("foo")
  end

  it "includes CloudFlare request ID header information in failure message" do
    expect(HTTParty).to receive(:get).with("https://hc-ping.com/foo").and_return(double(:response, code: 503, headers: { "cf-request-id" => "023aa754ae0000517ab8829200000001" }))
    expect(BarsoomUtils::ExceptionNotifier).to receive(:message).with(anything, /cf-request-id header: 023aa754ae0000517ab8829200000001/)

    BarsoomUtils::PingHealthCheck.call("foo")
  end

  it "silently reports an error to devs if it fails with a bad response code" do
    expect(HTTParty).to receive(:get).with("https://hc-ping.com/foo").and_return(double(:response, code: 404, headers: {}))
    expect(BarsoomUtils::ExceptionNotifier).to receive(:message).with(anything, /foo/)

    BarsoomUtils::PingHealthCheck.call("foo")
  end

  it "silently reports an error to devs if it fails with an exception" do
    expect(HTTParty).to receive(:get).with("https://hc-ping.com/foo").and_raise("fail")
    expect(BarsoomUtils::ExceptionNotifier).to receive(:message).with(anything, /foo/)

    BarsoomUtils::PingHealthCheck.call("foo")
  end
end
