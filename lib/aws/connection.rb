require 'httparty'
require 'openssl'

require 'aws/response'

module AWS

  class HTTP
    include HTTParty
    format :xml
  end

  ##
  # Handles all communication to and from AWS itself
  ##
  class Connection

    ##
    # Send a request to AWS proper, returning the response.
    # Will raise if the request has an error
    ##
    def call(request)
      AWS::Response.new(
        HTTP.send(request.method,
          request.uri,
          :query => request.params
        )
      )
    end

  end
end
