# frozen_string_literal: true
require "barsoom_utils/feature_toggle"

RSpec.describe BarsoomUtils::FeatureToggle, ".turn_on" do
  it "sets the feature as not disabled" do
    redis = double
    if Gem::Version.new(Redis::VERSION) <= "4.8.0"
      expect(redis).to receive(:srem).with("disabled_feature_toggles", "foo")
    else
      expect(redis).to receive(:srem?).with("disabled_feature_toggles", "foo")
    end
    BarsoomUtils::FeatureToggle.turn_on(:foo, redis: redis)
  end
end

RSpec.describe BarsoomUtils::FeatureToggle, ".turn_off" do
  it "sets the feature as disabled" do
    redis = double
    if Gem::Version.new(Redis::VERSION) <= "4.8.0"
      expect(redis).to receive(:sadd).with("disabled_feature_toggles", "foo")
    else
      expect(redis).to receive(:sadd?).with("disabled_feature_toggles", "foo")
    end
    BarsoomUtils::FeatureToggle.turn_off(:foo, redis: redis)
  end
end

RSpec.describe BarsoomUtils::FeatureToggle, ".on?, .off?" do
  let(:redis) { double(sismember: false) }

  context "by default" do
    specify { expect(BarsoomUtils::FeatureToggle.on?(:foo, redis: redis)).to be true }
    specify { expect(BarsoomUtils::FeatureToggle.off?(:foo, redis: redis)).to be false }
  end

  context "when disabled" do
    before do
      allow(redis).to receive(:sismember).with("disabled_feature_toggles", "foo").and_return(true)
    end

    specify { expect(BarsoomUtils::FeatureToggle.on?(:foo, redis: redis)).to be false }
    specify { expect(BarsoomUtils::FeatureToggle.off?(:foo, redis: redis)).to be true }
  end

  context "with a param override" do
    it "overrides the value in Redis" do
      expect(BarsoomUtils::FeatureToggle.on?(:foo, redis: redis)).to be true

      controller = double(params: { "ft_foo" => "false" })
      expect(BarsoomUtils::FeatureToggle.on?(:foo, controller, redis: redis)).to be false
      expect(BarsoomUtils::FeatureToggle.off?(:foo, controller, redis: redis)).to be true

      controller = double(params: { "ft_foo" => "true" })
      expect(BarsoomUtils::FeatureToggle.on?(:foo, controller, redis: redis)).to be true
      expect(BarsoomUtils::FeatureToggle.off?(:foo, controller, redis: redis)).to be false
    end
  end
end
