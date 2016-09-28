# ApiSim

![Build Tag](https://travis-ci.org/dugancathal/api_sim.svg?branch=master)

An HTTP API DSL on top of Sinatra.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'api_sim'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install api_sim

## Example usage

```ruby
require 'api_sim'

ENDPOINT_JSON_SCHEMA = {type: "object", properties: {a: {type: "integer"}}}.to_json

app = ApiSim.build_app do
  configure_endpoint 'GET', '/endpoint', 'Hi!', 200, {'X-CUSTOM-HEADER' => 'easy as abc'}, ENDPOINT_JSON_SCHEMA

  configure_dynamic_endpoint 'GET', '/dynamic', ->(req) {
    [201, {'X-CUSTOM-HEADER' => '123'}, 'Howdy!']
  }

  configure_matcher_endpoint 'POST', '/soap', {
    /Operation1/ => [200, {'Content-Type' => 'text/xml+soap'}, '<xml>Response1</xml>'],
    /Operation2/ => [500, {'Content-Type' => 'text/xml+soap'}, '<xml>Response2</xml>'],
  }
end

run app
```

The above is an exact copy of the `basic/config.ru` from the examples. You can boot this without too much
effort by running:

```bash
cd examples/basic && bundle check || bundle install && bundle exec rackup -I../../lib
```

After which the simulators should be running on port 9292.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dugancathal/api_sim.
