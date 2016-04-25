require 'sinatra/base'
require 'nokogiri'
require 'json'

class BuiltApp < Sinatra::Base
  ON_NO_MATCHER_FOUND = -> do
    raise 'No request has been configured for that request'
  end

  def self.endpoints(endpoints = nil)
    return @endpoints if @endpoints
    @endpoints = endpoints
  end

  put '/response/*' do
    route = "/#{params[:splat].first}"
    http_method = parsed_body['method'].upcase

    old_config = matcher(faux_request(http_method, route, request.body)).response(faux_request)

    status = parsed_body['status'] || old_config[0]
    headers = parsed_body['headers'] || old_config[1]
    body = parsed_body['body'] || old_config[2]
    self.class.endpoints.unshift(
      HttpSim::AppBuilder::StaticRequestMatcher.new(
        http_method: http_method,
        route: route,
        response_code: status,
        response_body: body,
        headers: headers
      )
    )
    ''
  end

  %i(get post put patch delete).each do |http_method|
    public_send(http_method, '/*') do
      matcher(request).response(request)
    end
  end

  private

  def matcher(request)
    self.class.endpoints.find(ON_NO_MATCHER_FOUND) do |matcher|
      matcher.matches?(request)
    end
  end

  def faux_request(method='', path='', body='')
    Rack::Request.new({'rack.input' => body, 'REQUEST_METHOD' => method, 'PATH_INFO' => path})
  end

  def parsed_body
    return @response_body if @response_body

    @response_body = case request.env['HTTP_CONTENT_TYPE']
                     when 'application/json' then
                       JSON.parse(request.body)
                     when 'application/xml' then
                       Nokogiri::XML(request.body)
                     else
                       request.body
                     end
  end
end
