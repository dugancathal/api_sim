require 'spec_helper'
require 'rack/test'

describe ApiSim do
  include Rack::Test::Methods
  def app
    @app
  end

  before do
    @app = ApiSim.build_app do
      configure_endpoint 'GET', '/endpoint', 'Hi!', 200, {'X-CUSTOM-HEADER' => 'easy as abc'}
      configure_endpoint 'POST', '/endpoint', {id: 42}.to_json, 200, {'X-CUSTOM-HEADER' => 'easy as abc'}
      configure_endpoint 'POST', '/post_endpoint', {id: 1}.to_json, 201, {'X-CUSTOM-HEADER' => 'now I know my abcs'}
      configure_endpoint 'GET', '/blogs/:blogId?commentAuthor=Simone', 'Only Comments by Simone', 200, {}
      configure_endpoint 'GET', '/blogs/:blogId', 'Imma Blerg!', 200, {'X-CUSTOM-HEADER' => 'blerg header'}

      configure_dynamic_endpoint 'GET', '/dynamic', ->(req) {
        [201, {'X-CUSTOM-HEADER' => '123'}, 'Howdy!']
      }

      configure_dynamic_endpoint 'POST', '/namespace/resource', ->(req) {
        [201, {'X-CUSTOM-HEADER' => '123'}, 'Howdy!']
      }

      configure_matcher_endpoint 'POST', '/matcher', {
        /key1/ => [202, {'X-CUSTOM-HEADER' => 'accepted'}, 'Yo1!'],
        /key2/ => [203, {'X-CUSTOM-HEADER' => 'I got this elsewhere'}, 'Yo2!'],
        /getAccountProfileResponse/ => [203, {'X-CUSTOM-HEADER' => 'I got this elsewhere'}, 'You done soap-ed it good'],
      }

      configure_fixture_directory File.expand_path('./fixtures', __dir__)
    end
  end

  it 'allows creation of a sinatra app' do
    expect(app.ancestors).to include(Sinatra::Base)
  end

  it 'can configure basic requests' do
    response = get '/endpoint'
    expect(response).to be_ok
    expect(response.body).to eq 'Hi!'
    expect(response.headers['X-CUSTOM-HEADER']).to eq 'easy as abc'
  end

  it 'can match on "parameterized" segments starting with a colon' do
    response = get '/blogs/5'
    expect(response).to be_ok
    expect(response.body).to eq 'Imma Blerg!'
    expect(response.headers['X-CUSTOM-HEADER']).to eq 'blerg header'
  end

  it 'does not match shorter or longer URLS on parameterized segments' do
    response = get '/blogs'
    expect(response).to be_not_found
    response = get '/blogs/5/nopes'
    expect(response).to be_not_found
  end

  it 'can configure dynamic responses that return their response via a proc' do
    response = get '/dynamic'
    expect(response).to be_created
    expect(response.body).to eq 'Howdy!'
    expect(response.headers['X-CUSTOM-HEADER']).to eq '123'
  end

  it 'can configure dynamic responses that match off the body' do
    response1 = post '/matcher', 'key1'
    expect(response1.status).to eq 202
    expect(response1.body).to eq 'Yo1!'
    expect(response1.headers['X-CUSTOM-HEADER']).to eq 'accepted'

    response2 = post '/matcher', 'key2'
    expect(response2.status).to eq 203
    expect(response2.body).to eq 'Yo2!'
    expect(response2.headers['X-CUSTOM-HEADER']).to eq 'I got this elsewhere'
  end

  it 'blows up when it has not configured an endpoint' do
    response = get '/matcher'
    expect(response.status).to eq 404
  end

  it 'can work with a valid Content-Type/Accept Header' do
    response2 = put '/response/dynamic', {body: 'new body', method: 'get'}.to_json, 'CONTENT_TYPE' => 'application/json; charset=utf8'
    expect(response2.status).to eq 200
  end

  it 'allows modification of the response for an endpoint' do
    put '/response/endpoint', {
      body: 'new body',
      method: 'get',
      headers: {'X-CUSTOM-HEADER' => 'is it though?'},
      status: 202
    }.to_json, 'CONTENT_TYPE' => 'application/json'

    response = get '/endpoint'
    expect(response.status).to eq 202
    expect(response.body).to eq 'new body'
    expect(response.headers['X-CUSTOM-HEADER']).to eq 'is it though?'
  end

  it 'allows modification of the response body for a dynamic endpoint' do
    put '/response/dynamic', {body: 'new body', method: 'get'}.to_json, 'CONTENT_TYPE' => 'application/json'

    response = get '/dynamic'
    File.write('/tmp/output', response.body)
    expect(response).to be_created
    expect(response.body).to eq 'new body'
    expect(response.headers['X-CUSTOM-HEADER']).to eq '123'
  end

  it 'allows modification of the response body for a matcher endpoint' do
    update_response = put '/response/matcher', {
      matcher: 'key1',
      body: 'new body',
      method: 'post'
    }.to_json, 'CONTENT_TYPE' => 'application/json'
    expect(update_response).to be_ok

    response = post '/matcher', 'key1'
    expect(response.status).to eq 202
    expect(response.body).to eq 'new body'
    expect(response.headers['X-CUSTOM-HEADER']).to eq 'accepted'

    response = post '/matcher', 'key2'
    expect(response.status).to eq 203
    expect(response.body).to eq 'Yo2!'
    expect(response.headers['X-CUSTOM-HEADER']).to eq 'I got this elsewhere'
  end

  it 'can reset to the default response' do
    update_response = put '/response/endpoint', {body: 'new body', method: 'get'}.to_json, 'CONTENT_TYPE' => 'application/json'
    expect(update_response).to be_ok

    delete_response = make_request_to 'DELETE', '/response/endpoint', {method: 'get'}.to_json, 'application/json'
    expect(delete_response).to be_ok

    response = get '/endpoint'
    expect(response).to be_ok
    expect(response.body).to eq 'Hi!'
    expect(response.headers).to include('X-CUSTOM-HEADER' => 'easy as abc')
  end

  it 'deletes the requests upon reset' do
    put '/response/endpoint', {body: 'new body', method: 'get'}.to_json, 'CONTENT_TYPE' => 'application/json'
    requests_response = get '/requests/GET/endpoint'
    expect(JSON.parse(requests_response.body)).to eq []

    get '/endpoint'
    requests_response = get '/requests/GET/endpoint'
    expect(JSON.parse(requests_response.body).count).to eq 1

    delete_response = make_request_to 'DELETE', '/response/endpoint', {method: 'get'}.to_json, 'application/json'
    File.write('/tmp/err.html', delete_response.body)
    expect(delete_response).to be_ok

    requests_response = get '/requests/GET/endpoint'
    expect(JSON.parse(requests_response.body)).to eq []
  end

  it 'can do matcher requests with XML data' do
    response = post '/matcher', <<-SOAP
      <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
        <SOAP-ENV:Header/>
        <SOAP-ENV:Body>
          <v13_0:getAccountProfileResponse xmlns:v13_0="http://www.dishnetwork.com/wsdl/AccountManagement/AccountManagement-v13.0">
            <serviceResponseContext>
              <displayMessage>1021InvalidSpaDisplayMessage</displayMessage>
            </serviceResponseContext>
          </v13_0:getAccountProfileResponse>
        </SOAP-ENV:Body>
      </SOAP-ENV:Envelope>
    SOAP

    expect(response.status).to eq 203
    expect(response.body).to eq 'You done soap-ed it good'
  end

  it 'allows extension of an existing ApiSim instance' do
    other_app = ApiSim.build_app do
      configure_endpoint 'GET', '/a-new-endpoint', 'You have been extended', 200
    end

    @app.use(other_app)

    response = get '/a-new-endpoint'

    expect(response.status).to eq 200
    expect(response.body).to eq 'You have been extended'
  end

  it 'allows retrieval of requests for endpoints with query params' do
    response = get '/blogs/3?commentAuthor=Simone'

    expect(response).to be_ok
    expect(response.body).to eq 'Only Comments by Simone'

    request_requests = get '/requests/GET/blogs/3?commentAuthor=Simone'
    expect(request_requests).to be_ok
    body = JSON.parse(request_requests.body)
    expect(body.count).to eq 1

    request_requests = get '/requests/GET/blogs/3'
    expect(request_requests).to be_ok
    body = JSON.parse(request_requests.body)
    expect(body.count).to eq 0
  end

  context 'requesting the requests for an endpoint' do
    it 'can request requests for endpoints' do
      put '/response/post_endpoint', {body: {id: 42}.to_json, method: 'post'}.to_json, 'CONTENT_TYPE' => 'application/json'

      requests_response = get '/requests/POST/post_endpoint'
      expect(requests_response).to be_ok
      expect(JSON.parse(requests_response.body)).to eq []

      post '/post_endpoint', {post: 'body'}.to_json, {'HTTP_ACCEPT' => 'application/json'}

      requests_response = get '/requests/POST/post_endpoint'
      expect(requests_response).to be_ok

      requests = JSON.parse(requests_response.body)
      expect(requests.count).to eq 1

      request = requests.first
      expect(request['headers']['accept']).to eq 'application/json'
      expect(request['body']).to eq({post: 'body'}.to_json)
      expect(request['path']).to eq('/post_endpoint')
      expect(Time.parse(request['time'])).to_not be_nil
    end

    it 'can request requests for endpoints with slashes in the url' do
      put '/response/namespace/resource', {body: {id: 42}.to_json, method: 'post'}.to_json, 'CONTENT_TYPE' => 'application/json'

      requests_response = get '/requests/POST/namespace/resource'
      expect(requests_response).to be_ok
      expect(JSON.parse(requests_response.body)).to eq []

      post '/namespace/resource', {foo: 'bar'}.to_json, {'HTTP_ACCEPT' => 'application/json'}

      requests_response = get '/requests/POST/namespace/resource'
      expect(requests_response).to be_ok

      requests = JSON.parse(requests_response.body)
      expect(requests.count).to eq 1

      request = requests.first
      expect(request['headers']['accept']).to eq 'application/json'
      expect(request['body']).to eq({foo: 'bar'}.to_json)
      expect(request['path']).to eq('/namespace/resource')
      expect(Time.parse(request['time'])).to_not be_nil
    end

    it 'defaults to getting the GET version if multiple endpoints with the same name exist' do
      put '/response/endpoint', {body: {id: 42}.to_json, method: 'get'}.to_json, 'CONTENT_TYPE' => 'application/json'
      put '/response/endpoint', {body: {id: 42}.to_json, method: 'post'}.to_json, 'CONTENT_TYPE' => 'application/json'

      requests_response = get '/requests/GET/endpoint'
      expect(requests_response).to be_ok
      expect(JSON.parse(requests_response.body)).to eq []

      get '/endpoint', nil, {'HTTP_ACCEPT' => 'application/json'}

      requests_response = get '/requests/GET/endpoint'
      expect(requests_response).to be_ok

      requests = JSON.parse(requests_response.body)
      expect(requests.count).to eq 1

      request = requests.first
      expect(request['headers']['accept']).to eq 'application/json'
      expect(request['path']).to eq('/endpoint')
      expect(Time.parse(request['time'])).to_not be_nil
    end

    it 'can differentiate on method when requesting requests with the same name and different http verbs' do
      put '/response/endpoint', {body: {id: 42}.to_json, method: 'get'}.to_json, 'CONTENT_TYPE' => 'application/json'
      put '/response/endpoint', {body: {id: 42}.to_json, method: 'post'}.to_json, 'CONTENT_TYPE' => 'application/json'

      requests_response = get '/requests/GET/endpoint'
      expect(requests_response).to be_ok
      expect(JSON.parse(requests_response.body)).to eq []

      get '/endpoint', nil, {'HTTP_ACCEPT' => 'application/json'}

      requests_response = get '/requests/GET/endpoint'
      expect(requests_response).to be_ok

      requests = JSON.parse(requests_response.body)
      expect(requests.count).to eq 1

      requests_response = get '/requests/POST/endpoint'
      expect(requests_response).to be_ok

      requests = JSON.parse(requests_response.body)
      expect(requests.count).to eq 0

      post '/endpoint', {foo: 'bar'}.to_json, {'HTTP_ACCEPT' => 'application/json'}

      requests_response = get '/requests/POST/endpoint'
      expect(requests_response).to be_ok

      requests = JSON.parse(requests_response.body)
      expect(requests.count).to eq 1

      request = requests.first
      expect(request['headers']['accept']).to eq 'application/json'
      expect(request['path']).to eq('/endpoint')
      expect(request['body']).to eq({foo: 'bar'}.to_json)
      expect(Time.parse(request['time'])).to_not be_nil
    end

    it 'allows retrieval of endpoint requests for "patterned" endpoints' do
      response = get '/blogs/34983943'
      expect(response).to be_ok

      requests = get '/requests/GET/blogs/34983943'
      expect(JSON.parse(requests.body).length).to eq 1
    end

    it 'returns query parameters for endpoints' do
      response = get '/blogs/34983943?q=stuff&fmt=summary&n=1'
      expect(response).to be_ok

      requests = get '/requests/GET/blogs/34983943'
      request_bodies = JSON.parse(requests.body)
      expect(request_bodies.length).to eq 1
      query = request_bodies.first['query']
      expect(query).to_not be_nil
      expect(query['q']).to eq('stuff')
      expect(query['fmt']).to eq('summary')
      expect(query['n']).to eq('1')
    end
  end

  it 'use a configured fixture directory' do
    response = get '/path/to/response'

    expect(response).to be_created
    expect(response.headers['content-type']).to eq 'application/json'

    response_body = JSON.parse(response.body)
    expect(response_body['id']).to eq 1
  end

  it 'records the incoming Content-Type' do
    make_request_to 'POST', '/endpoint', {'hi': 'mom'}.to_json, 'application/foo'

    get '/requests/POST/endpoint'

    body = JSON.parse(last_response.body)
    expect(body.length).to eq 1
    expect(body[0]['headers']['content-type']).to eq 'application/foo'
  end

  private
  def make_request_to(http_method, path, body, mime_type='application/json')
    env = {'rack.input' => Rack::Lint::InputWrapper.new(StringIO.new(body)), 'REQUEST_METHOD' => http_method.upcase, 'PATH_INFO' => path, 'CONTENT_TYPE' => mime_type}
    response_array = app.call(env)
    Rack::Response.new(response_array[2], response_array[0], response_array[1])
  end
end
