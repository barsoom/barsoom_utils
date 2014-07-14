require "spec_helper"
require "barsoom_utils/exception_notifier"

describe BarsoomUtils::ExceptionNotifier, ".notify" do
  before do
    stub_const("Honeybadger", double)
  end

  it "passes an exception to Honeybadger" do
    ex = StandardError.new("boom")
    expect(Honeybadger).to receive(:notify).with(ex)
    BarsoomUtils::ExceptionNotifier.notify(ex)
  end
end

describe BarsoomUtils::ExceptionNotifier, ".message" do
  before do
    stub_const("Honeybadger", double)
  end

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
