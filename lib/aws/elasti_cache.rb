require 'aws/api'
require 'aws/call_types/action_param'
require 'aws/signing/version2'

module AWS

  ##
  # Amazon's ElastiCache
  #
  # http://docs.amazonwebservices.com/AmazonElastiCache/latest/APIReference/
  #
  # All requests are POST and always through HTTPS. Use the third parameter to
  # #initialize if you need to talk to a region other than us-east-1.
  ##
  class ElastiCache < API
    endpoint "elasticache"
    use_https true
    version "2011-07-15"
    default_region "us-east-1"

    include CallTypes::ActionParam
    include Signing::Version2
  end

end
