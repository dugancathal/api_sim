require 'spec_helper'


module ApiSim::Matchers
  describe StaticRequestMatcher do
    it 'matches when the URL and METHOD are the same' do
      matcher = StaticRequestMatcher.new(http_method: 'GET', route: '/my/fancy/endpoint')

      matching_request = double(path: '/my/fancy/endpoint', request_method: 'GET')
      expect(matcher.matches?(matching_request)).to be_truthy
    end

    it 'matches when there are variable parts of the path' do
      matcher = StaticRequestMatcher.new(http_method: 'GET', route: '/my/:kind/endpoint')

      matching_request = double(path: '/my/fancy/endpoint', request_method: 'GET')
      expect(matcher.matches?(matching_request)).to be_truthy
    end

    it 'matches when there globs' do
      matcher = StaticRequestMatcher.new(http_method: 'GET', route: '/my/*')

      matching_request = double(path: '/my/fancy/endpoint', request_method: 'GET')
      expect(matcher.matches?(matching_request)).to be_truthy
    end

    it 'does not match ANYTHING when there is a glob' do
      matcher = StaticRequestMatcher.new(http_method: 'GET', route: '/foo/*')

      matching_request = double(path: '/my/fancy/endpoint', request_method: 'GET')
      expect(matcher.matches?(matching_request)).to be_falsy
    end
  end
end