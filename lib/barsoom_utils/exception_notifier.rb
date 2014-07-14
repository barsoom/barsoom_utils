# Notify devs about an exception without necessarily
# letting it appear to the user as a 500 error.

module BarsoomUtils
  class ExceptionNotifier
    def self.notify(exception)
      Honeybadger.notify(exception)
    end

    def self.message(message, details_or_context = nil, context_or_nothing = nil)
      if context_or_nothing
        details = details_or_context
        context = context_or_nothing
      elsif details_or_context.is_a?(Hash)
        details = nil
        context = details_or_context
      else
        details = details_or_context
        context = {}
      end

      details ||= "(no message)"

      Honeybadger.notify(
        error_class: message,
        error_message: details.to_s,
        context: context.to_h,
      )
    end
  end
end
