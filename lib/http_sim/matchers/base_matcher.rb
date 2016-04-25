require 'http_sim/recorded_request'

module HttpSim
  module Matchers
    class BaseMatcher
      DEFAULT_RACK_RESPONSE=[200, {}, '']
      ALWAYS_TRUE_MATCHER = ->(request) { true }

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
        @overridden = false
      end

      def requests
        @requests ||= []
      end

      def record_request(request)
        request.body.rewind
        requests.push(RecordedRequest.new(body: request.body.read, request_env: request.env))
      end

      def response(_)
        [response_code, headers, response_body]
      end
    end
  end
end