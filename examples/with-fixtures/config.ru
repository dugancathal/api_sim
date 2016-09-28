require 'api_sim'
require 'find'

DATA_DIR = File.expand_path('./data', __dir__)
endpoints = []
Find.find(DATA_DIR) do |path|
  next if Dir.exist?(path) # Skip directories
  http_method = File.basename(path, '.json') # our files are their HTTP method with the mime-type as the extension
  route = File.dirname(path).gsub(DATA_DIR, '') # the endpoint URL is everything else
  response = JSON.parse(File.read(path))
  status = response['status']
  headers = response['headers']
  body = response['body'].to_json
  schema = response['schema'].to_json
  puts "Configuring endpoint #{http_method} #{route}"
  endpoints << [
    http_method,
    route,
    body,
    status,
    headers,
    schema
  ]
end

app = ApiSim.build_app do
  endpoints.each {|endpoint| configure_endpoint(*endpoint) }
end

run app
