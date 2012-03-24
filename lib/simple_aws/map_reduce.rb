require 'simple_aws/api'
require 'simple_aws/call_types/action_param'
require 'simple_aws/signing/version2'

module SimpleAWS

  ##
  # Amazon's Elastic MapReduce
  #
  # http://docs.amazonwebservices.com/ElasticMapReduce/latest/API/
  #
  # All requests are POST and always through HTTPS. Use the third parameter to
  # `initialize` if you need to talk to a region other than us-east-1.
  #
  # @see SimpleAWS::CallTypes::ActionParam Calling rules
  # @see SimpleAWS::Response Response handling
  ##
  class MapReduce < API
    endpoint "elasticmapreduce"
    use_https true
    version "2009-03-31"

    include CallTypes::ActionParam
    include Signing::Version2
  end

end
