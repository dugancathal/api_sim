module HttpSim
  class AppBuilder
    class DynamicRequestMatcher
      attr_reader :response_generator, :route, :matcher, :http_method
      DEFAULT_RACK_RESPONSE=[200, {}, '']

      def initialize(http_method:, route:, response_generator:, matcher: ->(req) { true })
        @matcher = matcher
        @route = route
        @http_method = http_method
        @response_generator = response_generator
      end

      def matches?(request)
        request.path == route && request.request_method == http_method && matcher.call(request)
      end

      def response(request)
        response_generator.call(request)
      end
    end
  end
end