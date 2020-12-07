# frozen_string_literal: true
require "barsoom_utils/exception_notifier"

RSpec.describe BarsoomUtils::ExceptionNotifier do
  before do
    stub_const("Honeybadger", double)
  end

  describe ".notify" do
    it "passes an exception to Honeybadger" do
      ex = StandardError.new("boom")
      expect(Honeybadger).to receive(:notify).with(ex)
      BarsoomUtils::ExceptionNotifier.notify(ex)
    end

    it "can pass context info as well" do
      ex = StandardError.new("boom")
      expect(Honeybadger).to receive(:context).with(foo: "bar")
      expect(Honeybadger).to receive(:notify).with(ex)
      BarsoomUtils::ExceptionNotifier.notify(ex, context: { foo: "bar" })
    end

    it "complains if given a non-exception" do
      expect(Honeybadger).not_to receive(:notify)

      expect {
        BarsoomUtils::ExceptionNotifier.notify({ foo: "bar" })
      }.to raise_error(/Expected an exception but got:.*foo.*bar/)
    end
  end

  describe ".message" do
    it "passes a message to Honeybadger" do
      expect(Honeybadger).to receive(:notify).with(
        error_class: "Boom!",
        error_message: "(no message)",
        context: {},
      )
      BarsoomUtils::ExceptionNotifier.message("Boom!")

      expect(Honeybadger).to receive(:notify).with(
        error_class: "Boom!",
        error_message: "Details!",
        context: {},
      )
      BarsoomUtils::ExceptionNotifier.message("Boom!", "Details!")

      expect(Honeybadger).to receive(:notify).with(
        error_class: "Boom!",
        error_message: "Details!",
        context: { foo: "bar" },
      )
      BarsoomUtils::ExceptionNotifier.message("Boom!", "Details!", foo: "bar")

      expect(Honeybadger).to receive(:notify).with(
        error_class: "Boom!",
        error_message: "(no message)",
        context: { foo: "bar" },
      )
      BarsoomUtils::ExceptionNotifier.message("Boom!", foo: "bar")
    end
  end

  describe ".run_with_context" do
    it "passes an exception to Honeybadger, with context" do
      ex = StandardError.new("boom")
      expect(Honeybadger).to receive(:context).with({ ctx: "Yes, context" })
      expect(Honeybadger).to receive(:notify).with(ex)
      expect {
        BarsoomUtils::ExceptionNotifier.run_with_context({ ctx: "Yes, context" }) {
          raise ex
        }
      }.to raise_error /boom/
    end
  end

  describe ".developers_working_on_this_feature_are_responsible_for_errors_until" do

  end
end
