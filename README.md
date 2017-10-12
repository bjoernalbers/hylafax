# The Ruby HylaFAX Client

Send faxes with a
[HylaFAX](http://www.hylafax.org/)
server via Ruby.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hylafax'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hylafax


## Usage

Sending a fax:

```ruby
require 'hylafax'

HylaFAX.sendfax(dialstring: '0123456', document: 'foo.pdf')
```


## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `rake spec` to run the tests.
You can also run `bin/console` for an interactive prompt that will allow you to
experiment.


## Contributing

Bug reports and pull requests are welcome on
[GitHub](https://github.com/bjoernalbers/hylafax).
This project is intended to be a safe, welcoming space for collaboration, and
contributors are expected to adhere to the
[Contributor Covenant](http://contributor-covenant.org)
code of conduct.


## License

The gem is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).


## Code of Conduct

Everyone interacting in the project’s codebases, issue trackers, chat rooms and
mailing lists is expected to follow the
[code of conduct](https://github.com/bjoernalbers/hylafax/blob/master/CODE_OF_CONDUCT.md).
