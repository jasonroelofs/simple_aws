require 'httparty'
require 'openssl'

require 'aws/core/response'

##
# Monkey-patch body_stream usage into HTTParty
##
module HTTParty
  class Request
    private

    def setup_raw_request
      @raw_request = http_method.new(uri.request_uri)
      if body
        if body.respond_to?(:read)
          @raw_request.body_stream = body
        else
          @raw_request.body = body
        end
      end
      @raw_request.initialize_http_header(options[:headers])
      @raw_request.basic_auth(username, password) if options[:basic_auth]
      setup_digest_auth if options[:digest_auth]
    end

  end
end

module AWS

  class HTTP
    include HTTParty
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
