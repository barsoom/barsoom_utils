require "spec_helper"
require "barsoom_utils/spec/debug_helpers"

describe DebugHelpers do
  before { module Rails; end }

  let(:page) { double(:page, source: "wow such html") }
  let(:helper) { HelperTestClass.new(page) }

  it "writes the page to the filesystem" do
    allow(Rails).to receive(:root).and_return([])

    # writes the capybara page contents to the file system
    expect(File).to receive(:write).with("", page.source)

    # asserts that we expect a hostname to be defined
    expect { helper.show_page }.to raise_error(/Implement me/)
  end

  class HelperTestClass
    include DebugHelpers
    attr_accessor :page

    def initialize(page)
      @page = page
    end
  end
end
