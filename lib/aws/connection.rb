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

    attr_reader :api

    ##
    # Build a new connection handler to work with the given API
    ##
    def initialize(api)
      @api = api
    end

    ##
    # Send a request to AWS proper, returning the response.
    # Will raise if the request has an error
    ##
    def call(request)

      HTTP.get(
        @api.uri,
        :query => process_request(request)
      )
    end

    protected

    def process_request(request)
      params = {
        "Action" => request.action,
        "AWSAccessKeyId" => @api.access_key,
        "SignatureMethod" => "HmacSHA256",
        "SignatureVersion" => "2",
        "Timestamp" => Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ"),
        "Version" => @api.version
      }.merge request.params
    end

  end
end
