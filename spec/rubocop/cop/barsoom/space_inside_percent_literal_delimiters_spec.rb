# frozen_string_literal: true

require "rubocop_helper"

RSpec.describe RuboCop::Cop::Barsoom::SpaceInsidePercentLiteralDelimiters, :config do
  let(:ruby_version) { 3.4 }

  it "registers an offense for missing spaces, and adds them" do
    expect_offense(<<~'RUBY')
      %w[da de en]
         ^^^^^^^^ Use one space inside percent literal delimiters.
      %I[#{foo} bar]
         ^^^^^^^^^^ Use one space inside percent literal delimiters.
    RUBY

    expect_correction(<<~'RUBY')
      %w[ da de en ]
      %I[ #{foo} bar ]
    RUBY
  end

  it "registers an offense for extra or one-sided spaces, and evens them out" do
    expect_offense(<<~RUBY)
      %i[  foo bar  ]
         ^^^^^^^^^^^ Use one space inside percent literal delimiters.
      %i[foo bar ]
         ^^^^^^^^ Use one space inside percent literal delimiters.
    RUBY

    expect_correction(<<~RUBY)
      %i[ foo bar ]
      %i[ foo bar ]
    RUBY
  end

  it "keeps an escaped space at the end as part of the last element" do
    expect_offense(<<~'RUBY')
      %w[a b\ ]
         ^^^^^ Use one space inside percent literal delimiters.
    RUBY

    expect_correction(<<~'RUBY')
      %w[ a b\  ]
    RUBY
  end

  it "accepts one space, empty and multi-line literals, and regular arrays" do
    expect_no_offenses(<<~RUBY)
      %w[ da de en ]
      %w( da de en )
      %w[]
      %w[
        da
        de
      ]
      [ 1, 2 ]
    RUBY
  end
end
