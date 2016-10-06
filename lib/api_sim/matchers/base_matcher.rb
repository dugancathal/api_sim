require 'api_sim/recorded_request'

module ApiSim
  module Matchers
    class BaseMatcher
      DEFAULT_RACK_RESPONSE=[200, {}, '']
      ALWAYS_TRUE_MATCHER = ->(request) { true }
      attr_reader :request_schema

      def custom_matcher?
        matcher != ALWAYS_TRUE_MATCHER
      end

      def overridden!
        @overridden = true
      end

      def overridden?
        !!@overridden
      end

      def reset!
        @requests = []
        @overridden = false
      end

      def requests
        @requests ||= []
      end

      def match_on_body?
        false
      end

      def readonly?
        false
      end

      def record_request(request)
        request.body.rewind
        requests.push(RecordedRequest.new(body: request.body.read, request_env: request.env, request_path: request.path))
      end

      def to_s
        <<-DOC.gsub(/^\s+/, '')
          #{http_method} #{route}
        DOC
      end

      def response(_)
        [response_code, headers, response_body]
      end

      protected

      def matches_route_pattern?(request)
        route_tokens = route.split('/')
        request_tokens = request.path.split('/')

        return false if route_tokens.count != request_tokens.count && !route_tokens.include?('*')
        route_tokens.zip(request_tokens).all? do |matcher_part, request_part|
          break true if matcher_part == '*'
          matcher_part == request_part || matcher_part.start_with?(':')
        end
      end
    end
  end
end