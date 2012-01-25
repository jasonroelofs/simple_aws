require 'simple_aws/api'
require 'simple_aws/call_types/action_param'
require 'simple_aws/signing/version2'

module SimpleAWS

  ##
  # Amazon's Relational Database Service
  #
  # http://docs.amazonwebservices.com/AmazonRDS/latest/APIReference/
  #
  # All requests are POST and always through HTTPS. Use the third parameter to
  # #initialize if you need to talk to a region other than us-east-1.
  #
  # @see SimpleAWS::CallTypes::ActionParam Calling rules
  # @see SimpleAWS::Response Response handling
  ##
  class RDS < API
    endpoint "rds"
    use_https true
    version "2011-04-01"

    include CallTypes::ActionParam
    include Signing::Version2
  end

end
