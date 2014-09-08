require 'simple_aws/api'
require 'simple_aws/call_types/action_param'
require 'simple_aws/signing/version2'

module SimpleAWS

  ##
  # Amazon's Simple Queue Service
  #
  # http://docs.amazonwebservices.com/AWSSimpleQueueService/latest/APIReference/Welcome.html
  #
  # All requests are POST and always through HTTPS. Use the third parameter to
  # `initialize` if you need to talk to a region other than us-east-1.
  #
  # For the requests that act on a queue directly, like SendMessage, pass in the QueueURL
  # as the first parameter to the call:
  #
  #     sqs.send_message queue_url, params
  #
  # In accordance with the AWS documentation, SimpleAWS does not try to reconstruct
  # queue urls, use ListQueues or GetQueueUrl to get the correct queue url when needed.
  #
  # @see SimpleAWS::CallTypes::ActionParam Calling rules
  # @see SimpleAWS::Response Response handling
  ##
  class SQS < API
    endpoint "sqs"
    use_https true
    version "2012-11-05"
    default_region "us-east-1"

    include CallTypes::ActionParam
    include Signing::Version2

    # Special handling here, we need to look for a QueueURL as the first
    # parameter and update the request URI accordingly
    def method_missing(name, *args)
      if args.first.is_a?(String)
        request_uri = args.first
        params = args.last
      else
        request_uri = self.uri
        params = args.first
      end

      uri = URI.parse(request_uri)

      request = SimpleAWS::Request.new :post, "#{uri.scheme}://#{uri.host}", uri.path
      request.params["Action"] = SimpleAWS::Util.camelcase(name.to_s)

      if params.is_a?(Hash)
        insert_params_from request, params
      end

      send_request request
    end
  end

end
