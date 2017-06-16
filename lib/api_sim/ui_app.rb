require 'sinatra/base'
require 'api_sim/view_helpers'

module ApiSim
  module UiApp
    def self.with_root(root)
      Module.new do
        def self.registered(app)
          app.helpers ViewHelpers
          app.get "#{app.ui_root}" do
            erb :'index.html', layout: :'layout.html'
          end

          app.get "#{app.ui_root}/response/:method/*" do
            @config = matcher(faux_request(method: http_method, path: route, body: faux_body, query: request.query_string))
            erb :'responses/form.html', layout: :'layout.html'
          end

          app.get "#{app.ui_root}/requests/:method/*" do
            @config = matcher(faux_request(method: http_method, path: route, body: faux_body, query: request.query_string))

            erb :'requests/index.html', layout: :'layout.html'
          end

          app.post "#{app.ui_root}/response/:method/*" do
            @config = matcher(faux_request(method: http_method, path: route, body: faux_body, query: request.query_string))
            unless params['schema'].empty?
              @errors = JSON::Validator.fully_validate(JSON.parse(params['schema']), params['body'])
              if @errors.any?
                return erb :'responses/form.html', layout: :'layout.html'
              end
            end
            new_config = create_matcher_override(mimicked_request)

            self.class.endpoints.unshift(new_config)
            redirect to app.ui_root
          end

          app.delete "#{app.ui_root}/response/:method/*" do
            all_matching_matchers = matchers(mimicked_request)
            all_matching_matchers.each &:reset!
            non_default_matchers = all_matching_matchers.reject(&:default)
            self.class.endpoints.delete_if {|endpoint| non_default_matchers.include?(endpoint)}
            redirect to app.ui_root
          end
        end
      end
    end
  end
end
