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
      }.merge request.params

      params["Signature"] = escape(Base64.encode64(sign_request(params.clone)).chomp)

      p params

      params
    end

    def sign_request(params)
      list = params.to_a
      list.sort! do |a, b|
        if a[0] == "AWSAccessKeyId"
          -1
        else
          a[0] <=> b[0]
        end
      end

      to_sign = "POST\n#{@api.uri}\n\n#{list.map {|p| p.join("=") }.join("\n&")}"
      puts to_sign

      digest = OpenSSL::Digest::Digest.new("sha256")
      puts digest

      sig = OpenSSL::HMAC.digest(digest, @api.secret_key, to_sign)
      puts sig
      sig
    end

    # AWS URI escaping, as implemented by Fog
    def escape(string)
      string.gsub(/([^a-zA-Z0-9_.\-~]+)/) {
        "%" + $1.unpack("H2" * $1.bytesize).join("%").upcase
      }
    end

  end
end
