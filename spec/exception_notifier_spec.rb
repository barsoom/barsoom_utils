# frozen_string_literal: true
require "barsoom_utils/exception_notifier"
require "sentry-ruby"
require "fixme"

RSpec.describe BarsoomUtils::ExceptionNotifier do
  before do
    allow(Sentry).to receive(:capture_exception)
    allow(Sentry).to receive(:capture_message)
  end

  describe ".notify" do
    let(:ex) { StandardError.new("boom") }

    it "passes an exception to Sentry" do
      BarsoomUtils::ExceptionNotifier.notify(ex)

      expect(Sentry).to have_received(:capture_exception).with(ex, extra: {})
    end

    it "can pass through context info" do
      BarsoomUtils::ExceptionNotifier.notify(ex, context: { foo: "bar" })

      expect(Sentry).to have_received(:capture_exception).with(ex, extra: { foo: "bar" })
    end

    it "complains if given a non-exception" do
      expect {
        BarsoomUtils::ExceptionNotifier.notify({ foo: "bar" })
      }.to raise_error(/Expected an exception but got:.*foo.*bar/)

      expect(Sentry).not_to have_received(:capture_exception)
    end

    it "returns Sentry's result" do
      allow(Sentry).to receive(:capture_exception).and_return(:sentinel)

      expect(BarsoomUtils::ExceptionNotifier.notify(ex)).to eq(:sentinel)
    end

    it "raises without Sentry" do
      hide_const("Sentry")

      expect {
        BarsoomUtils::ExceptionNotifier.notify(ex)
      }.to raise_error(/Sentry is not available/)
    end
  end

  describe ".message" do
    it "passes a message to Sentry" do
      BarsoomUtils::ExceptionNotifier.message("Boom!")

      expect(Sentry).to have_received(:capture_message).with("Boom!", extra: {})
    end

    it "can take a custom details string" do
      BarsoomUtils::ExceptionNotifier.message("Boom!", "Details!")

      expect(Sentry).to have_received(:capture_message).with("Boom!: Details!", extra: {})
    end

    it "coerces the message to a string" do
      BarsoomUtils::ExceptionNotifier.message(:boom)

      expect(Sentry).to have_received(:capture_message).with("boom", extra: {})
    end

    it "can take a context hash" do
      BarsoomUtils::ExceptionNotifier.message("Boom!", foo: "bar")

      expect(Sentry).to have_received(:capture_message).with("Boom!", extra: { foo: "bar" })
    end

    it "can take a custom details string and a context hash" do
      BarsoomUtils::ExceptionNotifier.message("Boom!", "Details!", foo: "bar")

      expect(Sentry).to have_received(:capture_message).with("Boom!: Details!", extra: { foo: "bar" })
    end

    it "returns Sentry's result" do
      allow(Sentry).to receive(:capture_message).and_return(:sentinel)

      expect(BarsoomUtils::ExceptionNotifier.message("Boom!")).to eq(:sentinel)
    end

    it "raises without Sentry" do
      hide_const("Sentry")

      expect {
        BarsoomUtils::ExceptionNotifier.message("Boom!")
      }.to raise_error(/Sentry is not available/)
    end
  end
end
