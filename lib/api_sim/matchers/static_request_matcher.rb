require 'mustermann'
require 'api_sim/recorded_request'
require 'api_sim/matchers/base_matcher'

module ApiSim
  module Matchers
    class StaticRequestMatcher < BaseMatcher
      attr_reader :http_method, :route, :headers, :response_code, :matcher, :response_body, :default, :schema

      def initialize(**args)
        @default = args.fetch(:default, false)
        @matcher = args.fetch(:matcher, ALWAYS_TRUE_MATCHER)
        @headers = args.fetch(:headers, {})
        @response_body = args.fetch(:response_body, '')
        @response_code = args.fetch(:response_code, 200)
        @route = Mustermann.new(args.fetch(:route))
        @http_method = args.fetch(:http_method)
        @schema = args.fetch(:schema, nil)
        @request_schema = args.fetch(:request_schema, nil)
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
