# frozen_string_literal: true
module RuboCop
  module Cop
    module Barsoom
      # Checks for one space inside the delimiters of single-line array percent literals, matching the `[ a, b ]` style of `Layout/SpaceInsideArrayLiteralBrackets`.
      #
      # Empty and multi-line literals are accepted.
      #
      # @example
      #   # bad
      #   %w[da de en]
      #   %i[  foo bar  ]
      #
      #   # good
      #   %w[ da de en ]
      #   %i[ foo bar ]
      #   %w[]
      class SpaceInsidePercentLiteralDelimiters < Base
        extend AutoCorrector

        MSG = "Use one space inside percent literal delimiters."

        def on_array(node)
          return unless node.percent_literal? && node.single_line?

          body = node.source_range.with(begin_pos: node.loc.begin.end_pos, end_pos: node.loc.end.begin_pos)
          source = body.source
          return if source.strip.empty?

          leading = source[/\A */].length
          trailing = source[/ *\z/].length

          # In e.g. `%w[a\ ]`, the escaped space belongs to the element.
          trailing -= 1 if trailing.positive? && source[...-trailing][/\\*\z/].length.odd?

          return if leading == 1 && trailing == 1

          add_offense(body) do |corrector|
            corrector.replace(body, " #{source[leading...(source.length - trailing)]} ")
          end
        end
      end
    end
  end
end
