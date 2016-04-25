module HttpSim
  class AppBuilder
    class StaticRequestMatcher
      DEFAULT_RACK_RESPONSE=[200, {}, '']
      attr_reader :http_method, :route, :response, :headers, :response_code, :matcher, :response_body

      def initialize(http_method:, route:, response_code: 200, response_body: '', headers: {}, matcher: ->(req) { true })
        @matcher = matcher
        @headers = headers
        @response_body = response_body
        @response_code = response_code
        @route = route
        @http_method = http_method
      end

      def matches?(request)
        request.path == route && request.request_method == http_method && matcher.call(request)
      end

      def response(_)
        [response_code, headers, response_body]
      end
    end
  end
end