require 'spec_helper'


module ApiSim::Matchers
  describe DynamicRequestMatcher do
    it 'matches when the URL and METHOD are the same' do
      matcher = DynamicRequestMatcher.new(http_method: 'GET', route: '/my/fancy/endpoint', response_generator: nil)

      matching_request = double(path: '/my/fancy/endpoint', request_method: 'GET')
      expect(matcher.matches?(matching_request)).to be_truthy
    end

    it 'matches when there are variable parts of the path' do
      matcher = DynamicRequestMatcher.new(http_method: 'GET', route: '/my/:kind/endpoint', response_generator: nil)

      matching_request = double(path: '/my/fancy/endpoint', request_method: 'GET')
      expect(matcher.matches?(matching_request)).to be_truthy
    end

    it 'matches when there globs' do
      matcher = DynamicRequestMatcher.new(http_method: 'GET', route: '/my/*', response_generator: nil)

      matching_request = double(path: '/my/fancy/endpoint', request_method: 'GET')
      expect(matcher.matches?(matching_request)).to be_truthy
    end
  end
end