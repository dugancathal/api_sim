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

    it 'matches exact query strings if passed' do
      matcher = StaticRequestMatcher.new(http_method: 'GET', route: '/foo/bar?query_param=bar')

      matching_request = double(path: '/foo/bar', request_method: 'GET', query_string: nil)
      expect(matcher.matches?(matching_request)).to be_falsy

      matching_request = double(path: '/foo/bar', request_method: 'GET', query_string: 'query_param=bar')
      expect(matcher.matches?(matching_request)).to be_truthy

      matching_request = double(path: '/foo/bar', request_method: 'GET', query_string: 'query_param=nope')
      expect(matcher.matches?(matching_request)).to be_falsy
    end
  end
end
