# frozen_string_literal: true
require "rubocop_helper"

RSpec.describe RuboCop::Cop::Barsoom::InlinePrivateClassMethod, :config do
  let(:ruby_version) { 3.4 }

  it "registers an offense for listing class methods by name, and moves the modifier onto each definition" do
    expect_offense(<<~RUBY)
      class Foo
        def self.call = parse

        def self.parse
          :parsed
        end

        def self.verifier = :verifier

        private_class_method :parse, :verifier
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `private_class_method \\` before each `def self.` instead of listing the methods by name.
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        def self.call = parse

        private_class_method \\
        def self.parse
          :parsed
        end

        private_class_method \\
        def self.verifier = :verifier
      end
    RUBY
  end

  it "registers an offense without correcting it when some of the names aren't defined in the class body" do
    expect_offense(<<~RUBY)
      class Foo
        def self.build = new

        def self.parse = :parsed

        private_class_method :new, :parse
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `private_class_method \\` before each `def self.` instead of listing the methods by name.
      end
    RUBY

    expect_no_corrections
  end

  it "accepts the modifier before the definition" do
    expect_no_offenses(<<~RUBY)
      class Foo
        private_class_method \\
        def self.parse = :parsed

        private_class_method def self.verifier = :verifier
      end
    RUBY
  end

  it "accepts names that aren't defined with `def self.` in the class body" do
    expect_no_offenses(<<~RUBY)
      class Foo
        def self.build = new

        private_class_method :new
      end
    RUBY
  end
end
