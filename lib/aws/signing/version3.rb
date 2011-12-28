require 'openssl'

module AWS
  module Signing
    ##
    # Implementation of "Signature Version 3" signing, the X-Amzn-Authorization header
    ##
    module Version3

      ##
      # Build and sign the final request, as per the rules here:
      # http://docs.amazonwebservices.com/ses/latest/DeveloperGuide/QueryInterface.Authentication.html
      ##
      def finish_and_sign_request(request)
        timestamp = Time.now.utc
        request.params.merge!({
          "AWSAccessKeyId" => self.access_key,
          "Timestamp" => timestamp.strftime("%Y-%m-%dT%H:%M:%SZ"),
          "Version" => self.version
        })

        request.headers["Date"] = timestamp.httpdate

        request.headers["X-Amzn-Authorization"] =
          "AWS3-HTTPS AWSAccessKeyId=#{self.access_key}, " +
          "Algorithm=HmacSHA256, " +
          "Signature=#{Base64.encode64(build_signature_for(timestamp)).chomp}"

        request
      end

      def build_signature_for(timestamp)
        OpenSSL::HMAC.digest("sha256", self.secret_key, timestamp.httpdate)
      end

    end
  end
end
