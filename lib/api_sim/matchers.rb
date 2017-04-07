require 'api_sim/matchers/dynamic_request_matcher'
require 'api_sim/matchers/static_request_matcher'
require 'api_sim/matchers/request_body_matcher'

module ApiSim
  class Matcher
    OVERRIDE_CLASS_MAP = {
      Matchers::DynamicRequestMatcher => Matchers::StaticRequestMatcher,
      Matchers::StaticRequestMatcher => Matchers::StaticRequestMatcher,
      Matchers::RequestBodyMatcher => Matchers::RequestBodyMatcher,
    }

    def self.dupe_and_reconfigure(old_matcher, overrides)
      if old_matcher.match_on_body?
        Matchers::RequestBodyMatcher.new(
          route: old_matcher.route.to_s,
          http_method: old_matcher.http_method,
          response_code: overrides.fetch(:response_code),
          headers: overrides.fetch(:headers),
          response_body: overrides.fetch(:response_body),
          body_matches: overrides.fetch('matcher', old_matcher.matcher),
        )
      else
        Matchers::StaticRequestMatcher.new(
          route: old_matcher.route.to_s,
          query: old_matcher.query.to_s,
          http_method: old_matcher.http_method,
          response_code: overrides.fetch(:response_code),
          headers: overrides.fetch(:headers),
          response_body: overrides.fetch(:response_body),
          schema: overrides.fetch(:schema),
          request_schema: overrides.fetch(:request_schema)
        )
      end
    end
  end
end