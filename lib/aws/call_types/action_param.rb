require 'aws/util'
require 'aws/request'
require 'aws/connection'

module AWS
  module CallTypes

    ##
    # Implement call handling to work with the ?Action param, signing the message
    # according to that which is defined in EC2 and ELB.
    ##
    module ActionParam
      ##
      # For any undefined methods, try to convert them into valid AWS
      # actions and return the results
      ##
      def method_missing(name, *args)
        request = AWS::Request.new :post, self.uri, "/"
        request.params["Action"] = AWS::Util.camelcase(name.to_s)

        if args.any? && args.first.is_a?(Hash)
          args.first.each do |key, value|
            request.params[key] = value
          end
        end

        connection = AWS::Connection.new
        connection.call finish_and_sign_request(request)
      end

      protected

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

        request.params["Signature"] = Base64.encode64(sign_request(request.params.clone)).chomp

        request
      end

      def sign_request(params)
        list = params.map {|k, v| [k, Util.uri_escape(v.to_s)] }
        list.sort! do |a, b|
          if a[0] == "AWSAccessKeyId"
            -1
          else
            a[0] <=> b[0]
          end
        end

        host = self.uri.gsub(/^http[s]:\/\//,'')

        to_sign = "POST\n#{host}\n/\n#{list.map {|p| p.join("=") }.join("&")}"
        OpenSSL::HMAC.digest("sha256", self.secret_key, to_sign)
      end
    end
  end
end
