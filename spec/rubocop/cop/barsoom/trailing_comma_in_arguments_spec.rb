# frozen_string_literal: true

require "rubocop"
require "rubocop/rspec/support"
require "barsoom_utils/rubocop"

RSpec.describe RuboCop::Cop::Barsoom::TrailingCommaInArguments, :config do
  include RuboCop::RSpec::ExpectOffense

  context "when closing paren is on its own line" do
    it "registers an offense when trailing comma is missing" do
      expect_offense(<<~RUBY)
        foo(
          a,
          b
          ^ Put a trailing comma after the last argument when `)` is on the next line.
        )
      RUBY

      expect_correction(<<~RUBY)
        foo(
          a,
          b,
        )
      RUBY
    end

    it "accepts trailing comma" do
      expect_no_offenses(<<~RUBY)
        foo(
          a,
          b,
        )
      RUBY
    end

    it "accepts trailing comma when args share a line" do
      expect_no_offenses(<<~RUBY)
        foo(
          a, b,
        )
      RUBY
    end

    it "registers an offense for missing comma when args share a line" do
      expect_offense(<<~RUBY)
        foo(
          a, b
             ^ Put a trailing comma after the last argument when `)` is on the next line.
        )
      RUBY

      expect_correction(<<~RUBY)
        foo(
          a, b,
        )
      RUBY
    end
  end

  context "when closing paren is on the same line as last arg" do
    it "registers an offense when trailing comma is present" do
      expect_offense(<<~RUBY)
        foo(
          a,
          b,)
           ^ Remove the trailing comma when `)` is on the same line as the last argument.
      RUBY

      expect_correction(<<~RUBY)
        foo(
          a,
          b)
      RUBY
    end

    it "accepts no trailing comma" do
      expect_no_offenses(<<~RUBY)
        foo(
          a,
          b)
      RUBY
    end
  end

  context "single-line calls" do
    it "accepts no trailing comma" do
      expect_no_offenses(<<~RUBY)
        foo(a, b)
      RUBY
    end

    it "accepts a single argument" do
      expect_no_offenses(<<~RUBY)
        foo(a)
      RUBY
    end
  end

  context "safe navigation calls" do
    it "registers an offense when trailing comma is missing" do
      expect_offense(<<~RUBY)
        foo&.bar(
          a,
          b
          ^ Put a trailing comma after the last argument when `)` is on the next line.
        )
      RUBY

      expect_correction(<<~RUBY)
        foo&.bar(
          a,
          b,
        )
      RUBY
    end
  end

  context "with keyword arguments" do
    it "registers an offense when trailing comma is missing" do
      expect_offense(<<~RUBY)
        foo(
          key: "value"
          ^^^^^^^^^^^^ Put a trailing comma after the last argument when `)` is on the next line.
        )
      RUBY

      expect_correction(<<~RUBY)
        foo(
          key: "value",
        )
      RUBY
    end

    it "accepts trailing comma" do
      expect_no_offenses(<<~RUBY)
        foo(
          key: "value",
        )
      RUBY
    end

    it "accepts trailing comma followed by a comment" do
      expect_no_offenses(<<~RUBY)
        foo(
          key: "value", # some comment
        )
      RUBY
    end
  end

  context "with block pass argument" do
    it "ignores block pass on its own line" do
      expect_no_offenses(<<~RUBY)
        bar(
          a,
          &block
        )
      RUBY
    end
  end

  context "without parentheses" do
    it "ignores calls without parentheses" do
      expect_no_offenses(<<~RUBY)
        foo a,
          b
      RUBY
    end
  end

  context "without arguments" do
    it "ignores calls without arguments" do
      expect_no_offenses(<<~RUBY)
        foo()
      RUBY
    end
  end
end
