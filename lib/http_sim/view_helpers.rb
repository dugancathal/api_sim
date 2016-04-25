module HttpSim
  module ViewHelpers
    def endpoints
      self.class.endpoints.reject(&:overridden?)
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
  end
end