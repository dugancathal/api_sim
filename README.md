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

## API

API Sim has an HTTP API that allows you, the developer, to manage responses and verify
requests.

### The "Request/Response" API


#### Modify the response from an endpoint

The star in the path should match the request path that you want to update.
The "method" in the PUT request should match the HTTP method for the request.
```HTTP
HTTP/1.1 PUT /response/*
{
  "method": "post",
  "status": 999,
  "body": "{\"id\": 99}",
  "headers": {"NEW-HEADER": "output"}
}
```



#### Read requests made to an endpoint

The star in the path should match the path that you want to retrieve requests for.
```HTTP
GET /requests/:method/*
```

```HTTP
HTTP/1.1 200 OK

[
  {}
]
```

### 498

The API that these simulators generate can get pretty smart. To help you, the user,
distinguish between failures and "smarts", we've made up an HTTP status code: 498.
This code means "we received a request that did not match an expected schema". If you
provide the simulators with a request schema for an endpoint, all requests must match
that schema. If they do not, they'll receive our fictional status code.

## UI

The simulator application has a UI for manipulating and monitoring requests and responses.
You can view this UI by visiting `/ui` at the URL of the simulator.

Additionally, you can configure the endpoint for viewing the UI by adding to your config.ru.

```ruby
ui_root '/path/to/ui'
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dugancathal/api_sim.
