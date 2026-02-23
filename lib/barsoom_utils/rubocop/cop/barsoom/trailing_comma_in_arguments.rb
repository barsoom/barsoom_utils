# frozen_string_literal: true

module RuboCop
  module Cop
    module Barsoom
      # Require a trailing comma in multiline method arguments when the
      # closing `)` is on its own line. Disallow it when `)` is on the
      # same line as the last argument.
      #
      # This differs from the built-in `Style/TrailingCommaInArguments`:
      # - `comma` disallows trailing commas when args share a line.
      # - `consistent_comma` requires them even when `)` is on the same line.
      #
      # @example
      #   # good
      #   foo(
      #     a,
      #     b,
      #   )
      #
      #   # good – args sharing a line is fine as long as there's a trailing comma
      #   foo(
      #     a, b,
      #   )
      #
      #   # good – single-line
      #   foo(a, b)
      #
      #   # good – closing paren on same line as last arg
      #   foo(
      #     a, b)
      #
      #   # bad – missing trailing comma
      #   foo(
      #     a,
      #     b
      #   )
      #
      #   # bad – trailing comma but closing paren on same line
      #   foo(
      #     a, b,)
      class TrailingCommaInArguments < Base
        extend AutoCorrector

        MSG_MISSING = "Put a trailing comma after the last argument when `)` is on the next line."
        MSG_UNWANTED = "Remove the trailing comma when `)` is on the same line as the last argument."

        def on_send(node)
          check(node)
        end
        alias on_csend on_send

        private

        def check(node)
          return unless node.arguments? && node.parenthesized?

          close_paren_line = node.source_range.end.line
          last_arg = node.last_argument
          last_arg_line = last_arg.source_range.end.line

          return if close_paren_line == last_arg_line && close_paren_line == node.first_argument.first_line

          # A trailing comma after `&` is a syntax error.
          return if last_arg.block_pass_type?

          trailing_comma = trailing_comma_token(node)
          paren_on_own_line = close_paren_line > last_arg_line

          if paren_on_own_line && !trailing_comma
            add_offense_missing(last_arg)
          elsif !paren_on_own_line && trailing_comma
            add_offense_unwanted(trailing_comma)
          end
        end

        def add_offense_missing(last_arg)
          add_offense(last_arg, message: MSG_MISSING) do |corrector|
            corrector.insert_after(last_arg, ",")
          end
        end

        def add_offense_unwanted(comma_token)
          range = comma_token.pos
          add_offense(range, message: MSG_UNWANTED) do |corrector|
            corrector.remove(range)
          end
        end

        def trailing_comma_token(node)
          close_paren_idx = node.loc.end
          tokens = processed_source.tokens

          # Find the non-whitespace token just before the closing paren.
          tokens.reverse_each do |token|
            next if token.pos.end_pos > close_paren_idx.begin_pos
            next if token.comment? || token.type == :tNL
            return token if token.comma?
            return nil
          end
        end
      end
    end
  end
end
