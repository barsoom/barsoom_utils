require "httparty"
require "attr_extras"
require "barsoom_utils/exception_notifier"

module BarsoomUtils
  class PingHealthCheck
    method_object :id

    def call
      return unless ENV["ENABLE_HEALTH_CHECKS"]

      response = ping_healthcheck

      raise "Bad response #{response.inspect}" if response.code != 200
    rescue => ex
      BarsoomUtils::ExceptionNotifier.message("Couldn't report to healthchecks.io, maybe the service is down?", "Check: #{id}, Error: #{ex.inspect}")
    end

    private

    def ping_healthcheck
      HTTParty.get("https://hchk.io/#{id}")
    end
  end
end
