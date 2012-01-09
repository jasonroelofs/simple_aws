require 'aws/api'
require 'aws/call_types/action_param'
require 'aws/signing/version2'

module AWS

  ##
  # Amazon's Relational Database Service
  #
  # http://docs.amazonwebservices.com/AmazonRDS/latest/APIReference/
  #
  # All requests are POST and always through HTTPS. Use the third parameter to
  # #initialize if you need to talk to a region other than us-east-1.
  #
  # @see AWS::CallTypes::ActionParam Calling rules
  # @see AWS::Response Response handling
  ##
  class RDS < API
    endpoint "rds"
    use_https true
    version "2011-04-01"

    include CallTypes::ActionParam
    include Signing::Version2
  end

end
