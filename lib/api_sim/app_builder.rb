require 'api_sim/built_app'
require 'api_sim/matchers'

module ApiSim
  class AppBuilder
    NOT_FOUND = [nil, [404, {}, 'NOT FOUND']]

    def rackapp
      config = self
      Sinatra.new(BuiltApp) do
        endpoints config.endpoint_configurations
        ui_root config.ui_root || '/ui'
      end
    end

    def ui_root(root = nil)
      @ui_root = root if root
      @ui_root
    end

    def configure_endpoint(http_method, route, response_body, response_code=200, headers={}, schema_string='', request_schema: nil)
      endpoint_configurations.push(
        Matchers::StaticRequestMatcher.new(
          http_method: http_method,
          route: route,
          response_code: response_code,
          headers: headers,
          default: true,
          response_body: response_body,
          schema: schema_string,
          request_schema: request_schema
        )
      )
    end

    def configure_dynamic_endpoint(http_method, route, response_logic)
      endpoint_configurations.push(
        Matchers::DynamicRequestMatcher.new(
          http_method: http_method,
          route: route,
          default: true,
          response_generator: response_logic
        )
      )
    end

    def configure_matcher_endpoint(http_method, route, matchers_to_responses)
      matchers_to_responses.each do |matcher, response|
        endpoint_configurations.push(
          Matchers::RequestBodyMatcher.new(
            http_method: http_method,
            route: route,
            response_code: response[0],
            headers: response[1],
            response_body: response[2],
            default: true,
            body_matches: matcher,
          )
        )
      end
    end

    def configure_fixture_directory(dir)
      dir = dir.chomp('/')
      Dir[File.join(dir, "**/*.json.erb")].each do |path|
        endpoint_match = path.match(%r{#{dir}([/\w+\_\-]+)/(GET|POST|PATCH|OPTIONS|HEAD|PUT|DELETE).json})
        config = JSON.parse(File.read(path))
        request_schema = config['request_schema'].to_json unless config['request_schema'].nil?
        configure_endpoint endpoint_match[2],
          endpoint_match[1],
          config['body'].to_json,
          config['status'],
          config['headers'],
          config['schema'].to_json,
          request_schema: request_schema
      end
    end

    def endpoint_configurations
      @endpoint_configurations ||= []
    end
  end
end
