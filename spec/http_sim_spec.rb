require 'spec_helper'
require 'rack/test'

describe HttpSim do
  include Rack::Test::Methods
  def app
    @app
  end

  before do
    @app = HttpSim.build_app do
      configure_endpoint 'GET', '/endpoint', 'Hi!', 200, {'X-CUSTOM-HEADER' => 'easy as abc'}

      configure_dynamic_endpoint 'GET', '/dynamic', ->(req) {
        [201, {'X-CUSTOM-HEADER' => '123'}, 'Howdy!']
      }

      configure_matcher_endpoint 'POST', '/matcher', {
        /key1/ => [202, {'X-CUSTOM-HEADER' => 'accepted'}, 'Yo1!'],
        /key2/ => [203, {'X-CUSTOM-HEADER' => 'I got this elsewhere'}, 'Yo2!'],
      }
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
    expect(response.status).to eq 500
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

    delete_response = delete '/response/endpoint', {method: 'get'}.to_json, 'CONTENT_TYPE' => 'application/json'
    expect(delete_response).to be_ok

    response = get '/endpoint'
    expect(response).to be_ok
    expect(response.body).to eq 'Hi!'
    expect(response.headers).to include('X-CUSTOM-HEADER' => 'easy as abc')
  end

  private
  def make_request_to(http_method, path, body, mime_type='application/json')
    env = {'rack.input' => Rack::Lint::InputWrapper.new(body), 'REQUEST_METHOD' => http_method.upcase, 'PATH_INFO' => path, 'CONTENT_TYPE' => mime_type}
    response_array = app.call(env)
    Rack::Response.new(response_array[2], response_array[0], response_array[1])
  end
end
