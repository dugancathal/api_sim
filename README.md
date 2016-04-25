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
app = HttpSim.build_app do
  configure_dynamic_endpoint 'POST', '/foo', ->(request) do
    "whatever is returned will get output"
  end

  configure_endpoint 'GET', '/foo', 'Hi!', 200

  configure_endpoint 'GET', '/bar', '', 302, {'Location' => '/foo'}

  configure_soapy_endpoint 'POST', '/soap', {
    /Operation1/ => [200, {'Content-Type' => 'application/xml+soap'}, '<xml>Response1</xml>'],
    /Operation2/ => [500, {'Content-Type' => 'application/xml+soap'}, '<xml>Response2</xml>'],
  }
end

app.run!
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dugancathal/http_sim.
