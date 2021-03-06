# The Ruby HylaFAX Client

[![Gem Version](https://badge.fury.io/rb/hylafax.svg)](https://badge.fury.io/rb/hylafax)
[![Build Status](https://travis-ci.org/bjoernalbers/hylafax.svg?branch=master)](https://travis-ci.org/bjoernalbers/hylafax)

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

# Send fax and return the job id.
HylaFAX.sendfax(host: '10.2.2.1', dialstring: '0123456', document: 'foo.pdf')
# => 29

```

Checking fax statuses:

```ruby
# Query status by job id for completed faxes.
HylaFAX.faxstat(host: '10.2.2.1')
# => {29=>:done, 28=>:done, 27=>:failed}
```


## Development

You need to have Docker installed.
After checking out the repo, run the tests with:

    $ docker-compose run --rm lib bin/rspec

For an interactive prompt run:

    $ docker-compose run --rm lib bin/console

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
