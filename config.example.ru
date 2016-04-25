require 'http_sim'
require 'pp'
app = HttpSim.build_app do
  configure_endpoint 'GET', '/endpoint', 'Hi!', 200, {'X-CUSTOM-HEADER' => 'easy as abc'}

  configure_dynamic_endpoint 'GET', '/dynamic', ->(req) {
    [201, {'X-CUSTOM-HEADER' => '123'}, 'Howdy!']
  }

  configure_matcher_endpoint 'GET', '/matcher', {
    /key1/ => [202, {'X-CUSTOM-HEADER' => 'accepted'}, 'Yo!'],
    /key2/ => [203, {'X-CUSTOM-HEADER' => 'I got this elsewhere'}, 'Yo!'],
  }
end

pp app.endpoints
run app
