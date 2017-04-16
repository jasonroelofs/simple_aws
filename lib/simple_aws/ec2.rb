require 'simple_aws/api'
require 'simple_aws/call_types/action_param'
require 'simple_aws/signing/version2'

module SimpleAWS

  ##
  # Amazon's Elastic Computing Cloud
  #
  # http://docs.amazonwebservices.com/AWSEC2/latest/APIReference/index.html
  #
  # All requests are POST and always through HTTPS. Use the third parameter to
  # `initialize` if you need to talk to a region other than us-east-1.
  #
  # @see SimpleAWS::CallTypes::ActionParam Calling rules
  # @see SimpleAWS::Response Response handling
  ##
  class EC2 < API
    endpoint "ec2"
    use_https true
    version "2014-06-15"

    include CallTypes::ActionParam
    include Signing::Version2
  end

end
