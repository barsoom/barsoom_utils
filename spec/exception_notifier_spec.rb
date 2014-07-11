require "spec_helper"
require "barsoom_utils/exception_notifier"

describe ExceptionNotifier, ".notify" do
  before do
    stub_const("Honeybadger", double)
  end

  it "passes an exception to Honeybadger" do
    ex = StandardError.new("boom")
    expect(Honeybadger).to receive(:notify).with(ex)
    ExceptionNotifier.notify(ex)
  end
end

describe ExceptionNotifier, ".message" do
  before do
    stub_const("Honeybadger", double)
  end

  it "passes a message to Honeybadger" do

    expect(Honeybadger).to receive(:notify).with(
      error_class: "Boom!",
      error_message: "(no message)",
      context: {},
    )
    ExceptionNotifier.message("Boom!")

    expect(Honeybadger).to receive(:notify).with(
      error_class: "Boom!",
      error_message: "Details!",
      context: {},
    )
    ExceptionNotifier.message("Boom!", "Details!")

    expect(Honeybadger).to receive(:notify).with(
      error_class: "Boom!",
      error_message: "Details!",
      context: { foo: "bar" },
    )
    ExceptionNotifier.message("Boom!", "Details!", foo: "bar")

    expect(Honeybadger).to receive(:notify).with(
      error_class: "Boom!",
      error_message: "(no message)",
      context: { foo: "bar" },
    )
    ExceptionNotifier.message("Boom!", foo: "bar")
  end
end
