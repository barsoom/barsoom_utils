require "barsoom_utils/parse_space_separated_token_values"

RSpec.describe BarsoomUtils::ParseSpaceSeparatedTokenValues do
  let(:minimum_key_size) { 4 }
  let(:long_enough_api_key) { "xyza" }
  let(:token_name) { "API_TOKENS" }

  subject(:parsed_value) {
    described_class.call(token_name, minimum_key_size: minimum_key_size, data: { "API_TOKENS" => api_tokens_value })
  }

  context "with a valid set of tokens" do
    let(:api_tokens_value) { "#{long_enough_api_key} b#{long_enough_api_key}" }

    it "returns a frozen array" do
      expect(parsed_value).to(
        be_an(Array)
        .and(have_attributes(size: 2))
        .and(be_frozen)
      )
    end
  end

  context "with one too-short token" do
    let(:api_tokens_value) { "x #{long_enough_api_key}" }

    it "raises an error" do
      expect { parsed_value }.to raise_error(/Invalid API_TOKENS/)
    end
  end

  context "with a blank value" do
    let(:api_tokens_value) { "    " }

    it "raises an error" do
      expect { parsed_value }.to raise_error(/Missing API_TOKENS/)
    end
  end
end
