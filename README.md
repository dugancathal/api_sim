# HttpSim

An HTTP API DSL on top of Sinatra.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'http_sim'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install http_sim

## Example usage

```ruby
require 'http_sim'

ENDPOINT_JSON_SCHEMA = {"type": "object", "properties": {"a": {"type": "integer"}}}.to_json

app = HttpSim.build_app do
  configure_endpoint 'GET', '/endpoint', 'Hi!', 200, {'X-CUSTOM-HEADER' => 'easy as abc'}, ENDPOINT_JSON_SCHEMA

  configure_dynamic_endpoint 'GET', '/dynamic', ->(req) {
    [201, {'X-CUSTOM-HEADER' => '123'}, 'Howdy!']
  }

  configure_matcher_endpoint 'POST', '/matcher', {
    /key1/ => [202, {'X-CUSTOM-HEADER' => 'accepted'}, 'Yo!'],
    /key2/ => [203, {'X-CUSTOM-HEADER' => 'I got this elsewhere'}, 'Yo!'],
  }
end

run app
```

The above is an exact copy of the `config.example.ru` from the root of the repo. You can boot this without too much
effort by running:

```bash
bundle check || bundle install && bundle exec rackup -Ilib config.example.ru
```

After which the simulators should be running on port 9292.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dugancathal/http_sim.
