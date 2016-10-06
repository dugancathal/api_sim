require 'api_sim/built_app'
require 'api_sim/matchers'

module ApiSim
  class AppBuilder
    NOT_FOUND = [nil, [404, {}, 'NOT FOUND']]

    def rackapp
      config = self
      Class.new(BuiltApp) do
        endpoints config.endpoint_configurations
      end
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
            body_matches: matcher
          )
        )
      end
    end

    def endpoint_configurations
      @endpoint_configurations ||= []
    end
  end
end