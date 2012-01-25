require 'uri'
require 'openssl'

module SimpleAWS
  module Signing
    ##
    # Implementation of "Signature Version 2" signing
    ##
    module Version2

      ##
      # Build and sign the final request, as per the rules here:
      # http://docs.amazonwebservices.com/AWSEC2/latest/UserGuide/index.html?using-query-api.html
      ##
      def finish_and_sign_request(request)
        request.params.merge!({
          "AWSAccessKeyId" => self.access_key,
          "SignatureMethod" => "HmacSHA256",
          "SignatureVersion" => "2",
          "Timestamp" => Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ"),
          "Version" => self.version
        })

        request.params["Signature"] = Base64.encode64(sign_request(request)).chomp

        request
      end

      def sign_request(request)
        signing_params = request.params.clone

        list = signing_params.map {|k, v| [k, Util.uri_escape(v.to_s)] }
        list.sort! do |a, b|
          if a[0] == "AWSAccessKeyId"
            -1
          else
            a[0] <=> b[0]
          end
        end

        plain_host = URI.parse(request.host).host

        to_sign = "POST\n#{plain_host}\n#{request.path}\n#{list.map {|p| p.join("=") }.join("&")}"
        OpenSSL::HMAC.digest("sha256", self.secret_key, to_sign)
      end

    end
  end
end
