require 'http_sim'

ENDPOINT_JSON_SCHEMA = {"type": "object", "properties": {"a": {"type": "integer"}}}.to_json

app = HttpSim.build_app do
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
