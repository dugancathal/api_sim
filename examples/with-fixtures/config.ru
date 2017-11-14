require 'api_sim'
require 'find'

app = ApiSim.build_app do
  configure_fixture_directory './data'
end

run app
