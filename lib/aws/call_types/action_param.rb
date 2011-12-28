require 'aws/core/util'
require 'aws/core/request'
require 'aws/core/connection'
require 'uri'

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
          insert_params_from request, args.first
        end

        send_request request
      end

      protected

      def send_request(request)
        connection = AWS::Connection.new
        connection.call finish_and_sign_request(request)
      end

      def insert_params_from(request, args = {})
        args.each do |key, value|
          request.params[key] = value
        end
      end

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
