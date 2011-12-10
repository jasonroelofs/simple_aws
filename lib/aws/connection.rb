require 'httparty'

module AWS

  class HTTP
    include HTTParty
    format :xml
  end

  ##
  # Handles all communication to and from AWS itself
  ##
  class Connection

    attr_reader :uri

    ##
    # Build a new connection handler bound to the given URI
    ##
    def initialize(uri)
      @uri = uri
    end

    ##
    # Send a request to AWS proper, returning the response.
    # Will raise if the request has an error
    ##
    def call(request)
      HTTP.get(
        @uri,
        :query => {
          "Action" => request.action
        }.merge(request.params)
      )
    end

  end
end
