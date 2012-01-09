require 'aws/api'
require 'aws/call_types/action_param'
require 'aws/signing/version2'

module AWS

  ##
  # Amazon's Elastic Beanstalk
  #
  # http://docs.amazonwebservices.com/elasticbeanstalk/latest/api/
  #
  # All requests are POST and always through HTTPS. Use the third parameter to
  # #initialize if you need to talk to a region other than us-east-1.
  #
  # @see AWS::CallTypes::ActionParam Calling rules
  # @see AWS::Response Response handling
  ##
  class ElasticBeanstalk < API
    endpoint "elasticbeanstalk"
    use_https true
    version "2010-12-01"
    default_region "us-east-1"

    include CallTypes::ActionParam
    include Signing::Version2
  end

end
