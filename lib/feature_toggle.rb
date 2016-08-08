require "attr_extras"
require "redis"

module BarsoomUtils
  class FeatureToggle
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

    pattr_initialize :feature, [ :controller_or_view, :redis ]

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
      redis.set redis_key_for_disabling, "disabled"
    end

    def turn_on
      redis.del redis_key_for_disabling
    end

    private

    def has_param_override?
      controller_or_view && controller_or_view.params.has_key?("ft_#{feature}")
    end

    def on_according_to_param?
      value = controller_or_view && controller_or_view.params.fetch("ft_#{feature}")
      value == "true"
    end

    def on_according_to_redis?
      not redis.exists(redis_key_for_disabling)
    end

    def redis_key_for_disabling
      :"feature_#{feature}_disabled"
    end

    def redis
      @redis || $redis
    end
  end
end
