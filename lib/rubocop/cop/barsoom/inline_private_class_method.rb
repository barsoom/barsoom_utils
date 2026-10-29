# frozen_string_literal: true
module RuboCop
  module Cop
    module Barsoom
      # Checks for `private_class_method` listing class methods by name, when they're defined with `def self.` in the
      # same class body. Putting the modifier before each definition shows at a glance which class methods are private.
      # An endless method takes the modifier on the same line; a multi-line one on the line above, with a backslash.
      #
      # Names not defined that way, e.g. `private_class_method :new`, are accepted. The offense is only corrected when
      # every listed name is defined in the class body.
      #
      # @example
      #   # bad
      #   def self.parse(value) = Time.iso8601(value)
      #
      #   def self.verifier
      #     Rails.application.message_verifier("cursor")
      #   end
      #
      #   private_class_method :parse, :verifier
      #
      #   # good
      #   private_class_method def self.parse(value) = Time.iso8601(value)
      #
      #   private_class_method \
      #   def self.verifier
      #     Rails.application.message_verifier("cursor")
      #   end
      class InlinePrivateClassMethod < Base
        include RangeHelp
        extend AutoCorrector

        MSG = "Use `private_class_method` before each `def self.` instead of listing the methods by name."
        RESTRICT_ON_SEND = %i[private_class_method].freeze

        def on_send(node)
          return if node.receiver || node.arguments.empty? || !node.arguments.all?(&:sym_type?)

          definitions = class_method_definitions(node.parent)
          names = node.arguments.map(&:value)
          return if names.none? { |name| definitions.key?(name) }

          add_offense(node) do |corrector|
            next unless names.all? { |name| definitions.key?(name) }

            names.each do |name|
              definition = definitions.fetch(name)
              line_break = definition.endless? ? "" : "\\\n#{" " * definition.loc.column}"
              corrector.insert_before(definition, "private_class_method #{line_break}")
            end
            corrector.remove(removal_range(node))
          end
        end

        private

        def class_method_definitions(body)
          return {} unless body&.begin_type?

          body.each_child_node(:defs).select { |definition| definition.receiver.self_type? }.to_h { |definition| [ definition.method_name, definition ] }
        end

        # The whole line, and the blank line above it, so no blank line is left before the class's `end`.
        def removal_range(node)
          range = range_by_whole_lines(node.source_range, include_final_newline: true)
          previous_line = processed_source.lines[node.first_line - 2]
          previous_line&.strip&.empty? ? range.with(begin_pos: range.begin_pos - previous_line.length - 1) : range
        end
      end
    end
  end
end
