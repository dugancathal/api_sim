module HttpSim
  module ViewHelpers
    def endpoints
      self.class.endpoints.reject(&:overridden?).sort_by { |endpoint| [endpoint.http_method, endpoint.route].join(' ') }
    end

    def custom_matcher?(endpoint)
      endpoint.custom_matcher? ? '(Custom matcher)' : ''
    end

    def config
      @config
    end

    def route
      "/#{params[:splat].first}"
    end

    def link_to_response_edit(endpoint)
      match = endpoint.match_on_body? ? endpoint.matcher.source : ''
      <<-HTML
      <a href="/ui/response/#{endpoint.http_method}#{endpoint.route}?match=#{match}">
        #{endpoint.route}
      </a>
      HTML
    end

    def h(text)
      Rack::Utils.escape_html(text)
    end

    def link_to_read_requests(endpoint)
      match = endpoint.match_on_body? ? endpoint.matcher.source : ''
      <<-HTML
        <a href="/ui/requests/#{endpoint.http_method}#{endpoint.route}?match=#{match}">
          #{endpoint.requests.count}
        </a>
      HTML
    end
  end
end