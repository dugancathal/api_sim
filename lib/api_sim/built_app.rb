require 'sinatra/base'
require 'nokogiri'
require 'json'
require 'tilt/erb'
require 'json-schema'
require 'mustermann'
require 'api_sim/view_helpers'
require 'api_sim/ui_app'

module ApiSim
  class BuiltApp < Sinatra::Base
    API_REQUEST_MATCHER = Mustermann.new('/requests/:method{+path}')
    use Rack::MethodOverride

    def self.endpoints(endpoints = nil)
      @endpoints = endpoints if endpoints
      return @endpoints
    end

    def self.ui_root(root = nil)
      if root
        @ui_root = root
        self.register UiApp.with_root(root)
      end
      @ui_root
    end

    put '/response/*' do
      self.class.endpoints.unshift(create_matcher_override(mimicked_request))
      ''
    end

    delete '/response/*' do
      all_matching_matchers = matchers(mimicked_request)
      all_matching_matchers.each &:reset!
      non_default_matchers = all_matching_matchers.reject(&:default)
      self.class.endpoints.delete_if { |endpoint| non_default_matchers.include?(endpoint) }
      ''
    end

    get '/requests/*' do
      params = API_REQUEST_MATCHER.match(request.path) || halt(404)
      endpoint = matcher(faux_request(method: params['method'], path: params['path'], query: request.query_string))

      halt(404) unless endpoint
      endpoint.requests.to_json
    end

    %i(get post put patch delete options).each do |http_method|
      public_send(http_method, '/*') do
        endpoint = matcher(request)
        halt(498) unless schema_validates?(endpoint)
        endpoint.record_request(request)
        endpoint.response(request)
      end
    end

    private

    def active_endpoints
      self.class.endpoints.reject(&:overridden?)
    end

    def create_matcher_override(request)
      old_matcher = matcher(request)
      config = matcher_overrides(old_matcher.response(request))
      old_matcher.overridden!
      Matcher.dupe_and_reconfigure(old_matcher, config)
    end

    def matcher_overrides(old_config)
      parsed_body.merge(
        response_code: parsed_body.fetch('status', old_config[0]).to_i,
        headers: parsed_body.fetch('headers', old_config[1]),
        response_body: parsed_body.fetch('body', old_config[2]),
        matcher: parsed_body.fetch('match', ''),
        schema: parsed_body.fetch('schema', ''),
        request_schema: parsed_body.fetch('request-schema', nil)
      )
    end

    def mimicked_request
      faux_request(method: http_method, path: route, body: request.body, query: request.query_string)
    end

    def http_method
      parsed_body.fetch('method', params['method']).upcase
    end

    def matcher(request)
      matchers(request).first || halt(404)
    end

    def matchers(request)
      self.class.endpoints.select { |matcher| matcher.matches?(request) }
    end

    def faux_request(method: '', path: '', body: StringIO.new(''), query: '')
      body.rewind
      Rack::Request.new({'rack.input' => body, 'REQUEST_METHOD' => method, 'PATH_INFO' => path, 'QUERY_STRING' => query})
    end

    def faux_body
      StringIO.new(params[:match].to_s)
    end

    def parsed_body
      return @response_body if @response_body

      @response_body = case request.env['CONTENT_TYPE']
      when %r{application/json} then
        JSON.parse(request.body.read)
      when %r{text/xml} then
        Nokogiri::XML(request.body.read)
      when %r{application/x-www-form-urlencoded} then
        params
      else
        if request.path =~ /ui/
          params
        else
          request.body.read
        end
      end

      @response_body.empty? ? {} : @response_body
    end

    def schema_validates?(endpoint)
      if blank?(endpoint.request_schema) || request.env['CONTENT_TYPE'] != 'application/json'
        true
      else
        JSON::Validator.validate_json(JSON.parse(endpoint.request_schema), parsed_body.to_json)
      end
    end

    def route
      "/#{params[:splat].first}"
    end

    def blank?(item)
      item.nil? || item.empty?
    end
  end
end
