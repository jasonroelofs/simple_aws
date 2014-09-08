require 'simple_aws/api'
require 'simple_aws/call_types/action_param'
require 'simple_aws/signing/version2'

module SimpleAWS

  ##
  # Amazon's Elastic Load Balancing API
  #
  # http://docs.amazonwebservices.com/ElasticLoadBalancing/latest/APIReference/
  #
  # All requests are POST and always through HTTPS. Use the third parameter to
  # `initializer` if you need to talk to a region other than us-east-1.
  #
  # @see SimpleAWS::CallTypes::ActionParam Calling rules
  # @see SimpleAWS::Response Response handling
  ##
  class ELB < API
    endpoint "elasticloadbalancing"
    use_https true
    version "2012-06-01"

    include CallTypes::ActionParam
    include Signing::Version2
  end
end
