# BarsoomUtils

Barsoom Utils is our internal toolbox for small classes that we share in most of our projects.

This gem is intentionally not released since it's for internal use, but we keep it open
source since it might have some value for others.

## Installation

Add this line to your application's Gemfile:

    gem 'barsoom_utils', github: 'barsoom/barsoom_utils'

And then execute:

    $ bundle

## Usage

You need to explicitly require each class you want to use.
Also note that we use BarsoomUtils as namespace.

List of utils:

    require 'barsoom_utils/exception_notifier' #  Notify devs about an exception without necessarily letting it appear to the user as a 500 error.

## Developing

Running tests:

    rake

## Contributing

1. Fork it ( https://github.com/barsoom/barsoom_utils/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Credits and license

By [Barsoom](http://barsoom.se) under the MIT license:

Copyright (c) 2014 Barsoom AB

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
