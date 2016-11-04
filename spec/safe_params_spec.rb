require "spec_helper"
require "barsoom_utils/safe_params"

describe BarsoomUtils::SafeParams do
  let(:class_with_safe_params) {
    require "action_controller"

    Class.new(ActionController::Base) do
      include BarsoomUtils::SafeParams

      def permitted_param?(param)
        safe_params.include?(param) && safe_params.permitted?
      end
    end
  }

  it "parameters will be permitted" do
    foo = class_with_safe_params.new
    foo.params = { foo: "" }

    expect(foo.permitted_param?(:foo)).to be true
  end

  it "does not except 'host', 'port' or 'protocol' as safe params" do
    foo = class_with_safe_params.new
    foo.params = { host: "", port: "", protocol: "" }

    expect(foo.permitted_param?(:port)).to be false
    expect(foo.permitted_param?(:host)).to be false
    expect(foo.permitted_param?(:protocol)).to be false
  end
end
