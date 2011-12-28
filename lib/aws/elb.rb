require 'aws/api'
require 'aws/call_types/action_param'
require 'aws/signing/version2'

module AWS

  ##
  # Amazon's Elastic Load Balancing API
  #
  # http://docs.amazonwebservices.com/ElasticLoadBalancing/latest/APIReference/
  #
  # All requests are POST and always through HTTPS. Use the third parameter to
  # #initialize if you need to talk to a region other than us-east-1.
  ##
  class ELB < API
    endpoint "elasticloadbalancing"
    use_https true
    version "2011-11-15"

    include CallTypes::ActionParam
    include Signing::Version2
  end
end
