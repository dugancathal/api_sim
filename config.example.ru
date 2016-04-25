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
