require 'http_sim'

ENDPOINT_JSON_SCHEMA = {"type": "object", "properties": {"a": {"type": "integer"}}}.to_json

app = HttpSim.build_app do
  configure_endpoint 'GET', '/endpoint', 'Hi!', 200, {'CONTENT-TYPE' => 'application/json', 'X-CUSTOM-HEADER' => 'easy as abc'}, ENDPOINT_JSON_SCHEMA
  configure_endpoint 'GET', '/begin/:middle/end', 'You found an any-value path', 200, {'CONTENT-TYPE' => 'application/json'}

  configure_dynamic_endpoint 'GET', '/dynamic', ->(req) {
    [201, {'X-CUSTOM-HEADER' => '123'}, 'Howdy!']
  }

  configure_matcher_endpoint 'POST', '/matcher', {
    /Operation1/ => [200, {'Content-Type' => 'text/xml+soap'}, '<xml>Response1</xml>'],
    /Operation2/ => [500, {'Content-Type' => 'text/xml+soap'}, '<xml>Response2</xml>'],
  }
end

run app
