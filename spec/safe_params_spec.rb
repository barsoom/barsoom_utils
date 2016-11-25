require "spec_helper"
require "barsoom_utils/safe_params"

describe BarsoomUtils::SafeParams, "#safe_params" do
  let(:controller_or_view_class) {
    require "action_controller"

    Class.new(ActionController::Base) do
      include BarsoomUtils::SafeParams

      def permitted_param?(param)
        safe_params.include?(param) && safe_params.permitted?
      end
    end
  }

  it "permits most parameters without having to explicitly declare them" do
    controller_or_view = controller_or_view_class.new
    controller_or_view.params = { foo: "" }

    expect(controller_or_view.permitted_param?(:foo)).to be true
  end

  it "does not permit 'host', 'port' or 'protocol' as safe params" do
    controller_or_view = controller_or_view_class.new
    controller_or_view.params = { host: "", port: "", protocol: "" }

    expect(controller_or_view.permitted_param?(:port)).to be false
    expect(controller_or_view.permitted_param?(:host)).to be false
    expect(controller_or_view.permitted_param?(:protocol)).to be false
  end
end
