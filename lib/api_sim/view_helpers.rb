module ApiSim
  module ViewHelpers
    def endpoints
      self.class.endpoints.reject(&:overridden?).sort_by { |endpoint| [endpoint.http_method, endpoint.route].join(' ') }
    end

    def custom_matcher?(endpoint)
      endpoint.custom_matcher? ? '(Custom matcher)' : ''
    end

    def endpoint_query_string(endpoint)
      "?#{endpoint.query}" if endpoint.query != ''
    end

    def config
      @config
    end

    def link_to_response_edit(endpoint)
      match = endpoint.match_on_body? ? endpoint.matcher.source : ''
      <<-HTML
      <a href="#{ui_root}/response/#{endpoint.http_method}#{endpoint.route}?match=#{match}">
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
        <a href="#{ui_root}/requests/#{endpoint.http_method}#{endpoint.route}?match=#{match}">
          #{endpoint.requests.count}
        </a>
      HTML
    end

    def endpoint_match (endpoint)
      if endpoint.match_on_body? then
        "/#{endpoint.matcher.source}/"
      else
        ''
      end
    end

    def ui_root
      self.class.ui_root
    end
  end
end
