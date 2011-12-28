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

        request.headers["Date"] = timestamp.to_s

        request.headers["X-Amzn-Authorization"] =
          "AWS3-HTTPS AWSAccessKeyId=#{self.access_key}, " +
          "Algorithm=HmacSHA256, " +
          "Signature=#{build_signature_for(timestamp)}"

        request
      end

      def build_signature_for(timestamp)
        OpenSSL::HMAC.digest("sha256", self.secret_key, timestamp.to_s)
      end

    end
  end
end
