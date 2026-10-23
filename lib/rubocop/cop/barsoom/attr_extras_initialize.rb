# frozen_string_literal: true
module RuboCop
  module Cop
    module Barsoom
      # Checks for an `initialize` that only assigns each of its arguments to an instance variable of the same name.
      # attr_extras can define that for you.
      #
      # Positional defaults, splats and block arguments are accepted, since attr_extras has no equivalent. So are
      # keyword defaults other than immutable literals: attr_extras evaluates them once, when the class is loaded.
      #
      # @example
      #   # bad
      #   def initialize(user, notify:)
      #     @user = user
      #     @notify = notify
      #   end
      #
      #   # good
      #   pattr_initialize :user, [ :notify! ]
      class AttrExtrasInitialize < Base
        MSG = "Use attr_extras, e.g. `pattr_initialize`, instead of an `initialize` that only assigns its arguments."
        SUPPORTED_ARGUMENT_TYPES = %i[arg kwarg kwoptarg].freeze
        IMMUTABLE_DEFAULT_TYPES = %i[nil true false sym int float].freeze

        requires_gem "attr_extras"

        def on_def(node)
          return unless node.method?(:initialize)
          return unless node.each_ancestor(:class, :module, :sclass).first&.class_type?
          return unless supported_arguments?(node.arguments)
          return unless only_assigns?(node.body, node.arguments.map(&:name))

          add_offense(node.loc.keyword.join(node.loc.name))
        end

        private

        def supported_arguments?(arguments)
          arguments.any? && arguments.all? { |argument|
            SUPPORTED_ARGUMENT_TYPES.include?(argument.type) &&
              (!argument.kwoptarg_type? || IMMUTABLE_DEFAULT_TYPES.include?(argument.default_value.type))
          }
        end

        def only_assigns?(body, names)
          return false unless body

          statements = body.begin_type? ? body.children : [ body ]
          assigned = statements.map { |statement| assigned_argument(statement) }

          assigned.all? && assigned.sort == names.sort
        end

        def assigned_argument(statement)
          return unless statement.ivasgn_type? && statement.expression&.lvar_type?

          name = statement.expression.children.first
          name if statement.name == :"@#{name}"
        end
      end
    end
  end
end
