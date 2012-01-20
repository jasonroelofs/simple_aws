require 'aws/core/util'
require 'aws/core/request'
require 'aws/core/connection'

module AWS
  module CallTypes

    ##
    # Implement call handling to work with the ?Action param, signing the message
    # according to whatever Signing module is included along side this module.
    #
    # This module hooks up the `method_missing` functionality as described in the
    # README. To call methods on APIs including this module, simply call a method
    # with either the Ruby-fied name, or the full CamelCase name, and pass in
    # options required as the parameters.
    #
    # All responses will be wrapped up in an {AWS::Response AWS::Response} object.
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

    end
  end
end
