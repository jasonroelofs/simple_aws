require 'httparty'
require 'openssl'

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
      HTTP.post(
        @api.uri,
        :body => process_request(request)
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
      }

      request.params.each do |key, value|
        params[key] = escape value
      end

      params["Signature"] = Base64.encode64(sign_request(params.clone)).chomp

      params
    end

    ##
    # See the documentation for the rules concerning how this signing works:
    # http://docs.amazonwebservices.com/AWSEC2/latest/UserGuide/index.html?using-query-api.html
    ##
    def sign_request(params)
      list = params.map {|k, v| [k, escape(v)] }
      list.sort! do |a, b|
        if a[0] == "AWSAccessKeyId"
          -1
        else
          a[0] <=> b[0]
        end
      end

      host = @api.uri.gsub(/^http[s]:\/\//,'')

      to_sign = "POST\n#{host}\n/\n#{list.map {|p| p.join("=") }.join("&")}"
      digest = OpenSSL::Digest::Digest.new("sha256")
      OpenSSL::HMAC.digest(digest, @api.secret_key, to_sign)
    end

    # AWS URI escaping, as implemented by Fog
    def escape(string)
      # Quick hack for already escaped string, don't escape again
      # I don't think any requests require a % in a parameter, but if
      # there is one I'll need to rethink this
      return string if string =~ /%/

      string.gsub(/([^a-zA-Z0-9_.\-~]+)/) {
        "%" + $1.unpack("H2" * $1.bytesize).join("%").upcase
      }
    end

  end
end
