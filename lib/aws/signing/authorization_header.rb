require 'openssl'

module AWS
  module Signing
    ##
    # Implementation of signing using the Authorization header, as used by S3 and CloudFront
    ##
    module AuthorizationHeader

      ##
      # Build and sign the final request, as per the rules here:
      # http://s3.amazonaws.com/doc/s3-developer-guide/RESTAuthentication.html
      ##
      def finish_and_sign_request(request)
        request.headers["Date"] = Time.now.utc.httpdate
        request.headers["Authorization"] =
          "AWS #{self.access_key}:#{Base64.encode64(build_signature_for(request)).chomp}"

        request
      end

      def build_signature_for(request)
        amazon_headers = request.headers.select {|k, v|
          k =~ /^x-amz/i
        }.map {|k, v|
          "#{k.downcase}:#{v}".chomp
        }

        to_sign = [
          request.method.to_s.upcase,
          request.headers["Content-Md5"] || "",
          request.headers["Content-Type"] || "",
          request.headers["Date"],
          amazon_headers,
          request.path
        ].flatten.join("\n")

        OpenSSL::HMAC.digest("sha1", self.secret_key, to_sign)
      end

    end
  end
end
