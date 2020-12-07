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

  describe ".run_with_context" do
    it "updates the context just within the block" do
      allow(Honeybadger).to receive(:context).and_call_original
      Honeybadger.context({ my_old_context: "hello" })

      context_in_block = nil

      expect {
        BarsoomUtils::ExceptionNotifier.run_with_context({ my_new_context: "what up" }) do
          context_in_block = Honeybadger.get_context
          raise "boom"
        end
      }.to raise_error /boom/

      # Adds the new context while running the code.
      expect(context_in_block).to eq({ my_old_context: "hello", my_new_context: "what up" })

      # Resets the old context, without keeping the new.
      expect(Honeybadger.get_context).to eq({ my_old_context: "hello" })
    end
  end

  describe ".developers_working_on_this_feature_are_responsible_for_errors_until" do
    before do
      # We need some value, and this value means we don't have to rescue exceptions in some tests.
      set_rails_production(true)
    end

    it "notifies Honeybadger with a 'wip' tag" do
      ex = StandardError.new

      BarsoomUtils::ExceptionNotifier.developers_working_on_this_feature_are_responsible_for_errors_until("9999-01-01") do
        raise ex
      end

      expect(Honeybadger).to have_received(:notify).with(ex, context: { tags: "wip" })
    end

    it "does not raise the error in production" do
      set_rails_production(true)

      ex = StandardError.new

      expect {
        BarsoomUtils::ExceptionNotifier.developers_working_on_this_feature_are_responsible_for_errors_until("9999-01-01") do
          raise ex
        end
      }.not_to raise_error
    end

    it "raises the error in non-production" do
      set_rails_production(false)

      ex = StandardError.new

      expect {
        BarsoomUtils::ExceptionNotifier.developers_working_on_this_feature_are_responsible_for_errors_until("9999-01-01") do
          raise ex
        end
      }.to raise_error(ex)
    end

    it "sets a FIXME raise" do
      set_rails_production(false)

      expect {
        BarsoomUtils::ExceptionNotifier.developers_working_on_this_feature_are_responsible_for_errors_until("1999-01-01") do
          raise "hola"
        end
      }.to raise_error(Fixme::UnfixedError, /Fix by 1999-01-01: WIP error-handling/)
    end

    private

    def set_rails_production(bool)
      string_env = bool ? "production" : "test"
      stub_const("Rails", double(:rails, env: double(:env, production?: bool, to_s: string_env)))
    end
  end
end
