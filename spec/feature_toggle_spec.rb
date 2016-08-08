require "spec_helper"
require "barsoom_utils/feature_toggle"

describe BarsoomUtils::FeatureToggle, ".turn_on" do
  it "sets the feature as not disabled" do
    redis = double
    expect(redis).to receive(:del).with(:feature_foo_disabled)
    BarsoomUtils::FeatureToggle.turn_on(:foo, redis: redis)
  end
end

describe BarsoomUtils::FeatureToggle, ".turn_off" do
  it "sets the feature as always disabled" do
    redis = double
    expect(redis).to receive(:set).with(:feature_foo_disabled, "disabled")
    BarsoomUtils::FeatureToggle.turn_off(:foo, redis: redis)
  end
end

describe BarsoomUtils::FeatureToggle, "#on?, #off?, .on?, .off?" do
  let(:redis) { double(exists: false) }
  subject(:toggle) { BarsoomUtils::FeatureToggle.new(:foo, redis: redis) }

  context "by default" do
    it "turned on" do
      expect(BarsoomUtils::FeatureToggle.on?(:foo, redis: redis)).to eq(true)
      expect(BarsoomUtils::FeatureToggle.off?(:foo, redis: redis)).to eq(false)

      expect(BarsoomUtils::FeatureToggle.new(:foo, redis: redis).on?).to eq(true)
      expect(BarsoomUtils::FeatureToggle.new(:foo, redis: redis).off?).to eq(false)
    end
  end

  context "when always disabled" do
    before do
      redis_disable_value
    end

    it "turned off" do
      expect(BarsoomUtils::FeatureToggle.on?(:foo, redis: redis)).to eq(false)
      expect(BarsoomUtils::FeatureToggle.off?(:foo, redis: redis)).to eq(true)

      expect(BarsoomUtils::FeatureToggle.new(:foo, redis: redis).on?).to eq(false)
      expect(BarsoomUtils::FeatureToggle.new(:foo, redis: redis).off?).to eq(true)
    end
  end

  context "with a param override" do
    it "overrides the value in Redis" do
      expect(BarsoomUtils::FeatureToggle.on?(:foo, redis: redis)).to eq(true)

      controller = double(params: { "ft_foo" => "false" })
      expect(BarsoomUtils::FeatureToggle.on?(:foo, controller, redis: redis)).to eq(false)
      expect(BarsoomUtils::FeatureToggle.off?(:foo, controller, redis: redis)).to eq(true)

      controller = double(params: { "ft_foo" => "true" })
      expect(BarsoomUtils::FeatureToggle.on?(:foo, controller, redis: redis)).to eq(true)
      expect(BarsoomUtils::FeatureToggle.off?(:foo, controller, redis: redis)).to eq(false)
    end
  end

  private

  def redis_disable_value
    allow(redis).to receive(:exists).with(:feature_foo_disabled).and_return(true)
  end
end
