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

    it 'provides access to the route parameters in the response callback' do
      called = false
      verifier = ->(req) {
        called = true
        expect(req['part']).to eq('foo')
      }
      matcher = DynamicRequestMatcher.new(http_method: 'GET', route: '/my/:part', response_generator: verifier)
      matcher.response(double(path: '/my/foo'))
      expect(called).to be_truthy
    end
  end
end