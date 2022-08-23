# frozen_string_literal: true
require "httparty"
require "attr_extras"
require "barsoom_utils/exception_notifier"

module BarsoomUtils
  class PingHealthCheck
    method_object :id

    def call
      return unless ENV["ENABLE_HEALTH_CHECKS"]

      response = ping_healthcheck

      if response.code != 200
        # "The presence of the cf-request-id header in the response confirms
        # the request was proxied through Cloudflare"
        #   https://support.cloudflare.com/hc/en-us/articles/203118044-Gathering-information-for-troubleshooting-sites
        raise "Bad response, cf-request-id header: #{response.headers["cf-request-id"]}, response body: #{response.inspect}"
      else
        response
      end
    rescue => ex
      BarsoomUtils::ExceptionNotifier.message("Couldn't report to healthchecks.io, maybe the service is down?", "Check: #{id}, Error: #{ex.inspect}")
    end

    private

    def ping_healthcheck
      HTTParty.get("https://hc-ping.com/#{id}")
    end
  end
end
