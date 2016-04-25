require 'sinatra/base'
require 'nokogiri'
require 'json'
require 'tilt/erb'

module HttpSim
  class BuiltApp < Sinatra::Base
    use Rack::MethodOverride

    ON_NO_MATCHER_FOUND = -> do
      raise 'No response has been configured for that request'
    end

    def self.endpoints(endpoints = nil)
      return @endpoints if @endpoints
      @endpoints = endpoints
    end

    put '/response/*' do
      route = "/#{params[:splat].first}"
      http_method = parsed_body['method'].upcase

      old_matcher = matcher(faux_request(http_method, route, request.body))
      old_matcher.overridden!
      old_config = old_matcher.response(faux_request)

      status = parsed_body['status'] || old_config[0]
      headers = parsed_body['headers'] || old_config[1]
      body = parsed_body['body'] || old_config[2]
      if parsed_body['matcher']
        self.class.endpoints.unshift(
          Matchers::RequestBodyMatcher.new(
            http_method: http_method,
            route: route,
            response_code: status,
            response_body: body,
            headers: headers,
            body_matches: parsed_body['matcher'],
          )
        )
      else
        self.class.endpoints.unshift(
          Matchers::StaticRequestMatcher.new(
            http_method: http_method,
            route: route,
            response_code: status,
            response_body: body,
            headers: headers
          )
        )
      end
      ''
    end

    delete '/response/*' do
      route = "/#{params[:splat].first}"
      http_method = parsed_body['method'].upcase

      non_default_matchers = matchers(faux_request(http_method, route, request.body)).reject(&:default)
      self.class.endpoints.delete_if { |endpoint| non_default_matchers.include?(endpoint) }
      ''
    end

    get '/' do
      erb :'index.html', layout: :'layout.html'
    end

    get '/ui/response/:method/*' do
      route = "/#{params[:splat].first}"
      http_method = params['method'].upcase
      @config = matcher(faux_request(http_method, route, request.body))
      erb :'responses/form.html', layout: :'layout.html'
    end

    post '/ui/response/:method/*' do
      route = "/#{params[:splat].first}"
      http_method = params['method'].upcase
      @config = matcher(faux_request(http_method, route, request.body))
      @config.overridden!

      new_config = Matchers::StaticRequestMatcher.new(
        http_method: http_method,
        route: route,
        response_code: params['response-code'].to_i,
        response_body: params['response-body'],
        headers: @config.headers
      )

      self.class.endpoints.unshift(new_config)
      redirect to '/'
    end

    delete '/ui/response/:method/*' do
      route = "/#{params[:splat].first}"
      http_method = params['method'].upcase

      all_matching_matchers = matchers(faux_request(http_method, route, request.body))
      all_matching_matchers.each &:reset!
      non_default_matchers = all_matching_matchers.reject(&:default)
      self.class.endpoints.delete_if { |endpoint| non_default_matchers.include?(endpoint) }
      redirect to '/'
    end

    get '/ui/requests/:method/*' do
      route = "/#{params[:splat].first}"
      http_method = params['method'].upcase
      @config = matcher(faux_request(http_method, route, request.body))

      erb :'requests/index.html', layout: :'layout.html'
    end

    %i(get post put patch delete).each do |http_method|
      public_send(http_method, '/*') do
        endpoint = matcher(request)
        endpoint.record_request(request)
        endpoint.response(request)
      end
    end

    helpers do
      def endpoints
        self.class.endpoints.reject(&:overridden?)
      end

      def custom_matcher?(endpoint)
        endpoint.custom_matcher? ? '(Custom matcher)' : ''
      end

      def config
        @config
      end
    end

    private

    def matcher(request)
      matchers(request).first
    end

    def matchers(request)
      self.class.endpoints.select { |matcher| matcher.matches?(request) }
    end

    def faux_request(method='', path='', body=StringIO.new(''))
      body.rewind
      Rack::Request.new({'rack.input' => body, 'REQUEST_METHOD' => method, 'PATH_INFO' => path})
    end

    def parsed_body
      return @response_body if @response_body

      @response_body = case request.env['CONTENT_TYPE']
                       when 'application/json' then
                         JSON.parse(request.body.read)
                       when 'application/xml' then
                         Nokogiri::XML(request.body.read)
                       else
                         request.body.read
                       end
    end
  end
end