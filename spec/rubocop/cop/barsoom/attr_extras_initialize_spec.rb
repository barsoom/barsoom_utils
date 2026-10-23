# frozen_string_literal: true
require "rubocop_helper"

RSpec.describe RuboCop::Cop::Barsoom::AttrExtrasInitialize, :config do
  let(:gem_versions) { { "attr_extras" => "7.1.0" } }

  it "registers an offense for an initialize that only assigns its positional arguments" do
    expect_offense(<<~RUBY)
      class Foo
        def initialize(bar, baz)
        ^^^^^^^^^^^^^^ Use attr_extras, e.g. `pattr_initialize`, instead of an `initialize` that only assigns its arguments.
          @bar = bar
          @baz = baz
        end
      end
    RUBY
  end

  it "registers an offense for required keyword arguments" do
    expect_offense(<<~RUBY)
      class Foo
        def initialize(bar, baz:)
        ^^^^^^^^^^^^^^ Use attr_extras, e.g. `pattr_initialize`, instead of an `initialize` that only assigns its arguments.
          @bar = bar
          @baz = baz
        end
      end
    RUBY
  end

  it "registers an offense for keyword arguments with immutable literal defaults" do
    expect_offense(<<~RUBY)
      class Foo
        def initialize(bar: nil, baz: :qux, limit: 10)
        ^^^^^^^^^^^^^^ Use attr_extras, e.g. `pattr_initialize`, instead of an `initialize` that only assigns its arguments.
          @bar = bar
          @baz = baz
          @limit = limit
        end
      end
    RUBY
  end

  it "accepts keyword defaults that attr_extras would evaluate once, at load time" do
    expect_no_offenses(<<~RUBY)
      class Foo
        def initialize(now: Time.now, list: [], name: "x")
          @now = now
          @list = list
          @name = name
        end
      end
    RUBY
  end

  it "accepts positional defaults, which attr_extras doesn't support" do
    expect_no_offenses(<<~RUBY)
      class Foo
        def initialize(bar, baz = nil)
          @bar = bar
          @baz = baz
        end
      end
    RUBY
  end

  it "accepts splat and block arguments" do
    expect_no_offenses(<<~RUBY)
      class Foo
        def initialize(*bars, **opts, &block)
          @bars = bars
          @opts = opts
          @block = block
        end
      end
    RUBY
  end

  it "accepts an initialize that does anything besides assigning its arguments" do
    expect_no_offenses(<<~RUBY)
      class Foo
        def initialize(bar, baz)
          @bar = bar
          @baz = baz.to_s
          @qux = []
        end
      end
    RUBY
  end

  it "accepts an initialize that calls super" do
    expect_no_offenses(<<~RUBY)
      class Foo < Base
        def initialize(bar)
          super()
          @bar = bar
        end
      end
    RUBY
  end

  it "accepts instance variables named differently from the arguments" do
    expect_no_offenses(<<~RUBY)
      class Foo
        def initialize(bar)
          @baz = bar
        end
      end
    RUBY
  end

  it "accepts an initialize that leaves an argument unassigned" do
    expect_no_offenses(<<~RUBY)
      class Foo
        def initialize(bar, _baz)
          @bar = bar
        end
      end
    RUBY
  end

  it "accepts an initialize without arguments" do
    expect_no_offenses(<<~RUBY)
      class Foo
        def initialize
        end
      end
    RUBY
  end

  it "accepts an initialize in a module" do
    expect_no_offenses(<<~RUBY)
      module Foo
        def initialize(bar)
          @bar = bar
        end
      end
    RUBY
  end

  context "when the project doesn't use attr_extras" do
    let(:gem_versions) { {} }

    it "accepts the initialize" do
      expect_no_offenses(<<~RUBY)
        class Foo
          def initialize(bar)
            @bar = bar
          end
        end
      RUBY
    end
  end
end
