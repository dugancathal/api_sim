require 'http_sim/recorded_request'
require 'http_sim/matchers/base_matcher'

module HttpSim
  module Matchers
    class DynamicRequestMatcher < BaseMatcher
      attr_reader :response_generator, :route, :http_method, :default, :matcher

      def initialize(http_method:, route:, response_generator:, default: false, matcher: ALWAYS_TRUE_MATCHER)
        @matcher = matcher
        @route = route
        @http_method = http_method
        @default = default
        @response_generator = response_generator
      end

      def matches?(request)
        request.path == route && request.request_method == http_method && matcher.call(request)
      end

      def response(request)
        response_generator.call(request)
      end

      def readonly?
        true
      end
    end
  end
end