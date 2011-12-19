require 'aws/api'
require 'aws/call_types/action_param'

module AWS

  ##
  # Hook into Amazon's Elastic Computing Cloud
  #
  # Intended usage of this API is simple, just call the methods you want and give these
  # methods the parameters as defined in the official API documentation:
  #
  # http://docs.amazonwebservices.com/AWSEC2/latest/APIReference/index.html
  #
  # For example, to run a DescribeInstances call:
  #
  #   ec2 = AWS::EC2.new "access_key", "secret_key"
  #   response = ec2.describe_instances(
  #     "InstanceId" => ["i-12345", "i-23456"]
  #   )
  #
  # See AWS::Request for specific details on what hand-holding is done in
  # terms of passing Ruby types like Arrays or Hashes. You can always just
  # pass in raw AWS params, like so:
  #
  #   ec2 = AWS::EC2.new "access_key", "secret_key"
  #   response = ec2.describe_instances(
  #     "InstanceId.1" => "i-12345",
  #     "InstanceId.2" => "i-23456"
  #   )
  #
  # See AWS::Response for details on what you can do with the Response object.
  #
  # All requests are POST and always through HTTPS. Use the third parameter to
  # #initialize if you need to talk to a region other than us-east-1.
  ##
  class EC2 < API
    endpoint "ec2"
    use_https true
    version "2011-11-01"

    include CallTypes::ActionParam
  end

end
