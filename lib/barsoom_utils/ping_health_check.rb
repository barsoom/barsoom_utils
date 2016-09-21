require "httparty"
require "barsoom_utils/exception_notifier"

module BarsoomUtils
  class PingHealthCheck
    method_object :id

    def call
      return unless ENV["ENABLE_HEALTH_CHECKS"]

      response = HTTParty.get("https://hchk.io/#{id}")

      unless response.code == 200
        BarsoomUtils::ExceptionNotifier.message("Couldn't report to healthchecks.io, maybe the service is down?", "Check: #{id}")
      end
    end
  end
end
