# frozen_string_literal: true
# Notify devs about an exception without necessarily
# letting it appear to the user as a 500 error.

module BarsoomUtils
  class ExceptionNotifier
    def self.notify(exception, context: {})
      # Inelegant workaround for the fact that we've confused this method with .message at least once.
      # TODO: Fold them into a single method?
      unless exception.is_a?(Exception)
        raise "Expected an exception but got: #{exception.inspect}"
      end

      ensure_notifier!

      result = Honeybadger.notify(exception, context: context) if defined?(Honeybadger)
      Sentry.capture_exception(exception, extra: context) if defined?(Sentry)
      result
    end

    def self.message(message, details_or_context = nil, context_or_nothing = nil)
      ensure_notifier!

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

      if defined?(Honeybadger)
        result = Honeybadger.notify(
          error_class: message,
          error_message: (details || "(no message)").to_s,
          context: context.to_h,
        )
      end

      if defined?(Sentry)
        title = details ? "#{message}: #{details}" : message.to_s
        Sentry.capture_message(title, extra: context.to_h)
      end

      result
    end

    private

    private_class_method \
    def self.ensure_notifier!
      return if defined?(Honeybadger) || defined?(Sentry)

      raise "Cannot notify: neither Honeybadger nor Sentry is available."
    end
  end
end
