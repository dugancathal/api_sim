require 'forwardable'
require 'mustermann'
require 'api_sim/recorded_request'
require 'api_sim/matchers/base_matcher'

module ApiSim
  module Matchers
    class DynamicRequestMatcher < BaseMatcher
      attr_reader :response_generator, :route, :http_method, :default, :matcher, :query

      def initialize(http_method:, route:, response_generator:, default: false, matcher: ALWAYS_TRUE_MATCHER)
        @matcher = matcher
        @route = Mustermann.new(route)
        @http_method = http_method
        @default = default
        @response_generator = response_generator
      end

      def matches?(request)
        matches_route_pattern?(request) && request.request_method == http_method && matcher.call(request)
      end

      def response(request)
        response_generator.call(SmartRequest.new(request, self))
      end

      def readonly?
        true
      end

      def to_s
        <<-DOC.gsub(/^\s+/, '')
          #{http_method} #{route} -> DYNAMIC BASED ON REQUEST
        DOC
      end
    end
  end

  class SmartRequest < SimpleDelegator
    def initialize(obj, matcher)
      super(obj)
      @matcher = matcher
    end

    def [](requested_part)
      @matcher.route.match(path)[requested_part]
    end
  end
end
