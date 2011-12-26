require 'aws/api'
require 'aws/call_types/action_param'

module AWS

  ##
  # Amazon's Simple Notification Service
  #
  # http://docs.amazonwebservices.com/sns/latest/api/Welcome.html
  #
  # All requests are POST and always through HTTPS. Use the third parameter to
  # #initialize if you need to talk to a region other than us-east-1.
  ##
  class SNS < API
    endpoint "sns"
    use_https true
    version "2010-03-31"
    default_region "us-east-1"

    include CallTypes::ActionParam
  end

end
