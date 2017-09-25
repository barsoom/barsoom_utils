require "attr_extras"
require "redis"

module BarsoomUtils
  class FeatureToggle
    # We (counter-intuitively, perhaps) store disabled toggles, so we can assume them to be enabled by default in dev, staging and tests.
    REDIS_KEY = "disabled_feature_toggles"

    def self.on?(feature, controller_or_view = nil, redis: $redis)
      new(feature, controller_or_view: controller_or_view, redis: redis).on?
    end

    def self.off?(feature, controller_or_view = nil, redis: $redis)
      new(feature, controller_or_view: controller_or_view, redis: redis).off?
    end

    def self.turn_on(feature, redis: $redis)
      new(feature, redis: redis).turn_on
    end

    def self.turn_off(feature, redis: $redis)
      new(feature, redis: redis).turn_off
    end

    pattr_initialize :feature_name, [ :controller_or_view, :redis ]

    def on?
      if has_param_override?
        on_according_to_param?
      else
        on_according_to_redis?
      end
    end

    def off?
      not on?
    end

    def turn_off
      redis.sadd REDIS_KEY, feature_name
    end

    def turn_on
      redis.srem REDIS_KEY, feature_name
    end

    private

    def has_param_override?
      controller_or_view && controller_or_view.params.has_key?("ft_#{feature_name}")
    end

    def on_according_to_param?
      value = controller_or_view && controller_or_view.params["ft_#{feature_name}"]
      value == "true"
    end

    def on_according_to_redis?
      not redis.sismember(REDIS_KEY, feature_name)
    end

    def redis
      @redis || $redis
    end

    def feature_name
      @feature_name.to_s
    end
  end
end
