# This is useful when you have parameters that doesn't bother with strong params security.
# So use this in place of params when generating links etc.
#
# See https://github.com/rails/rails/issues/26289

module BarsoomUtils
  module SafeParams
    def self.included(c)
      c.helper_method :safe_params
    end

    private

    def safe_params
      params.except(:host, :port, :protocol).permit!
    end
  end
end
