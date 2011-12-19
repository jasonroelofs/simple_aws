require 'aws/api'
require 'aws/call_types/action_param'

module AWS

  ##
  # Amazon's ElasticLoadBalancing API
  #
  # http://docs.amazonwebservices.com/ElasticLoadBalancing/latest/APIReference/
  ##
  class ELB < API
    endpoint "elasticloadbalancing"
    use_https true
    version "2011-11-15"

    include CallTypes::ActionParam
  end
end
