# frozen_string_literal: true
require "barsoom_utils/exception_notifier"
require "honeybadger"
require "sentry-ruby"
require "fixme"

RSpec.describe BarsoomUtils::ExceptionNotifier do
  before do
    allow(Honeybadger).to receive(:notify)
    allow(Sentry).to receive(:capture_exception)
    allow(Sentry).to receive(:capture_message)
  end

  describe ".notify" do
    let(:ex) { StandardError.new("boom") }

    it "passes an exception to Honeybadger and Sentry" do
      BarsoomUtils::ExceptionNotifier.notify(ex)

      expect(Honeybadger).to have_received(:notify).with(ex, context: {})
      expect(Sentry).to have_received(:capture_exception).with(ex, extra: {})
    end

    it "can pass through context info" do
      BarsoomUtils::ExceptionNotifier.notify(ex, context: { foo: "bar" })

      expect(Honeybadger).to have_received(:notify).with(ex, context: { foo: "bar" })
      expect(Sentry).to have_received(:capture_exception).with(ex, extra: { foo: "bar" })
    end

    it "complains if given a non-exception" do
      expect {
        BarsoomUtils::ExceptionNotifier.notify({ foo: "bar" })
      }.to raise_error(/Expected an exception but got:.*foo.*bar/)

      expect(Honeybadger).not_to have_received(:notify)
      expect(Sentry).not_to have_received(:capture_exception)
    end

    it "returns Honeybadger's result" do
      allow(Honeybadger).to receive(:notify).and_return(:sentinel)

      expect(BarsoomUtils::ExceptionNotifier.notify(ex)).to eq(:sentinel)
    end

    context "without Sentry" do
      before { hide_const("Sentry") }

      it "still notifies Honeybadger and raises nothing" do
        BarsoomUtils::ExceptionNotifier.notify(ex, context: { foo: "bar" })

        expect(Honeybadger).to have_received(:notify).with(ex, context: { foo: "bar" })
      end
    end
  end

  describe ".message" do
    it "passes a message to Honeybadger and Sentry" do
      BarsoomUtils::ExceptionNotifier.message("Boom!")

      expect(Honeybadger).to have_received(:notify).with(
        error_class: "Boom!",
        error_message: "(no message)",
        context: {},
      )
      expect(Sentry).to have_received(:capture_message).with("Boom!", extra: {})
    end

    it "can take a custom details string" do
      BarsoomUtils::ExceptionNotifier.message("Boom!", "Details!")

      expect(Honeybadger).to have_received(:notify).with(
        error_class: "Boom!",
        error_message: "Details!",
        context: {},
      )
      expect(Sentry).to have_received(:capture_message).with("Boom!: Details!", extra: {})
    end

    it "coerces the message to a string for Sentry" do
      BarsoomUtils::ExceptionNotifier.message(:boom)

      expect(Sentry).to have_received(:capture_message).with("boom", extra: {})
    end

    it "can take a context hash" do
      BarsoomUtils::ExceptionNotifier.message("Boom!", foo: "bar")

      expect(Honeybadger).to have_received(:notify).with(
        error_class: "Boom!",
        error_message: "(no message)",
        context: { foo: "bar" },
      )
      expect(Sentry).to have_received(:capture_message).with("Boom!", extra: { foo: "bar" })
    end

    it "can take a custom details string and a context hash" do
      BarsoomUtils::ExceptionNotifier.message("Boom!", "Details!", foo: "bar")

      expect(Honeybadger).to have_received(:notify).with(
        error_class: "Boom!",
        error_message: "Details!",
        context: { foo: "bar" },
      )
      expect(Sentry).to have_received(:capture_message).with("Boom!: Details!", extra: { foo: "bar" })
    end

    it "returns Honeybadger's result" do
      allow(Honeybadger).to receive(:notify).and_return(:sentinel)

      expect(BarsoomUtils::ExceptionNotifier.message("Boom!")).to eq(:sentinel)
    end

    context "without Sentry" do
      before { hide_const("Sentry") }

      it "still notifies Honeybadger and raises nothing" do
        BarsoomUtils::ExceptionNotifier.message("Boom!", "Details!", foo: "bar")

        expect(Honeybadger).to have_received(:notify).with(
          error_class: "Boom!",
          error_message: "Details!",
          context: { foo: "bar" },
        )
      end
    end
  end
end
