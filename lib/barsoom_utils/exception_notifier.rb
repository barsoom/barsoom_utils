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

      Honeybadger.notify(exception, context: context)
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

    # Wrap this around code to add context when reporting errors.
    def self.run_with_context(context, &block)
      # The load/dump achieves a "deep dup" without the "deep dep" of Active Support 🥁
      old_context = Marshal.load(Marshal.dump(Honeybadger.get_context))

      Honeybadger.context(context)
      block.call
    ensure
      Honeybadger.context.clear!
      Honeybadger.context(old_context)
    end

    # While developing a feature we'd like the feature developers to be responsible for any errors that occur.
    # Wrapping the new code with this tags the errors as "wip" in order to hide them from the dashboard.
    def self.developers_working_on_this_feature_are_responsible_for_errors_until(expire_on, &block)
      block.call
    rescue => ex
      FIXME "#{expire_on}: WIP error-handling code needs to be removed!"
      notify(ex, context: { tags: "wip" })

      is_rails_production = defined?(Rails) && Rails.env.production?
      raise unless is_rails_production
    end
  end
end
