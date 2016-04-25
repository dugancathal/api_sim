module HttpSim
  class RecordedRequest
    attr_reader :time, :headers, :body

    def initialize(time: Time.now, body:, request_env:)
      @time = time
      @body = body
      @headers = parse_headers_from(request_env)
    end

    private
    def parse_headers_from(request_env)
      request_env.select do |k, v|
        k =~ /^HTTP_/
      end.each_with_object({}) do |(k, v), h|
        h[k.split('_')[1..-1].join('-')] = v
      end.sort
    end
  end
end