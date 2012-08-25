require 'httparty'
require 'openssl'

require 'simple_aws/core/response'

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

module SimpleAWS

  ##
  # Custom response parser to handle the various craziness of the AWS API
  ##
  class SimpleAWSParser < HTTParty::Parser
    SupportedFormats.merge!(
      {"application/x-amz-json-1.0" => :json}
    )

    def parse
      if supports_format?
        super
      elsif body =~ %r{<\?xml}
        xml
      else
        body
      end
    end
  end

  class HTTP
    include HTTParty
    parser SimpleAWSParser
  end

  ##
  # Handles all communication to and from AWS itself
  ##
  class Connection

    def initialize(api)
      @api = api
    end

    ##
    # Send an SimpleAWS::Request to AWS proper, returning an SimpleAWS::Response.
    # Will raise if the request has an error
    ##
    def call(request)
      SimpleAWS::Response.new(
        HTTP.send(request.method,
          request.uri,
          :query => request.params,
          :headers => request.headers,
          :body => request.body,
          :debug_output => @api.debug_to
        )
      )
    end

  end
end
