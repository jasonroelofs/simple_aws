require 'httparty'
require 'httmultiparty'
require 'openssl'

require 'aws/core/response'

module AWS

  class HTTP
    include HTTMultiParty
  end

  ##
  # Handles all communication to and from AWS itself
  ##
  class Connection

    ##
    # Send an AWS::Request to AWS proper, returning an AWS::Response.
    # Will raise if the request has an error
    ##
    def call(request)
      AWS::Response.new(
        HTTP.send(request.method,
          request.uri,
          :query => request.params,
          :headers => request.headers,
          :body => request.body
        )
      )
    end

  end
end
