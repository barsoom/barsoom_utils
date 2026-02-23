# frozen_string_literal: true
require "barsoom_utils/exception_notifier"
require "honeybadger"
require "fixme"

RSpec.describe BarsoomUtils::ExceptionNotifier do
  before do
    allow(Honeybadger).to receive(:notify)
  end

  describe ".notify" do
    let(:ex) { StandardError.new("boom") }

    it "passes an exception to Honeybadger" do
      BarsoomUtils::ExceptionNotifier.notify(ex)

      expect(Honeybadger).to have_received(:notify).with(ex, context: {})
    end

    it "can pass through context info" do
      BarsoomUtils::ExceptionNotifier.notify(ex, context: { foo: "bar" })

      expect(Honeybadger).to have_received(:notify).with(ex, context: { foo: "bar" })
    end

    it "complains if given a non-exception" do
      expect {
        BarsoomUtils::ExceptionNotifier.notify({ foo: "bar" })
      }.to raise_error(/Expected an exception but got:.*foo.*bar/)

      expect(Honeybadger).not_to have_received(:notify)
    end
  end

  describe ".message" do
    it "passes a message to Honeybadger" do
      BarsoomUtils::ExceptionNotifier.message("Boom!")

      expect(Honeybadger).to have_received(:notify).with(
        error_class: "Boom!",
        error_message: "(no message)",
        context: {},
      )
    end

    it "can take a custom details string" do
      BarsoomUtils::ExceptionNotifier.message("Boom!", "Details!")

      expect(Honeybadger).to have_received(:notify).with(
        error_class: "Boom!",
        error_message: "Details!",
        context: {},
      )
    end

    it "can take a context hash" do
      BarsoomUtils::ExceptionNotifier.message("Boom!", foo: "bar")

      expect(Honeybadger).to have_received(:notify).with(
        error_class: "Boom!",
        error_message: "(no message)",
        context: { foo: "bar" },
      )
    end

    it "can take a custom details string and a context hash" do
      BarsoomUtils::ExceptionNotifier.message("Boom!", "Details!", foo: "bar")

      expect(Honeybadger).to have_received(:notify).with(
        error_class: "Boom!",
        error_message: "Details!",
        context: { foo: "bar" },
      )
    end
  end
end
