require 'api_sim/recorded_request'
require 'api_sim/matchers/base_matcher'

module ApiSim
  module Matchers
    class StaticRequestMatcher < BaseMatcher
      attr_reader :http_method, :route, :headers, :response_code, :matcher, :response_body, :default, :schema

      def initialize(http_method:, route:, response_code: 200, response_body: '', headers: {}, default: false, matcher: ALWAYS_TRUE_MATCHER, schema: nil)
        @default = default
        @matcher = matcher
        @headers = headers
        @response_body = response_body
        @response_code = response_code
        @route = route
        @http_method = http_method
        @schema = schema
      end

      def matches?(request)
        matches_route_pattern?(request) && request.request_method == http_method && matcher.call(request)
      end

      def overridden!
        @overridden = true
      end

      def overridden?
        !!@overridden
      end

      def to_s
        <<-DOC.gsub(/^\s+/, '')
          #{http_method} #{route} -> (#{response_code}) #{response_body[0..20]}...
        DOC
      end
    end
  end
end
