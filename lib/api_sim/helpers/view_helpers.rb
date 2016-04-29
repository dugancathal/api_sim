module ViewHelpers

  def self.endpoint_match (endpoint)
    if endpoint.match_on_body? then
      "/#{endpoint.matcher.source}/"
    else
      ''
    end
  end

end

