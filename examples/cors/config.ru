require 'rack/cors'
require 'api_sim'

app = ApiSim.build_app do
  configure_endpoint 'GET', '/endpoint', 'Hi!', 200, {'X-CUSTOM-HEADER' => 'easy as abc'}
end

# See the documentation for Rack::Cors for all the options here.
use Rack::Cors do
  allow do
    origins '*'
    resource '/*',
      :methods => [:get, :post, :delete, :put, :patch, :options, :head],
      :headers => :any,
      :max_age => 600
  end
end

run app
