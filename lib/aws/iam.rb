require 'aws/api'
require 'aws/call_types/action_param'

module AWS

  ##
  # Amazon's Identity and Access Management
  #
  # http://docs.amazonwebservices.com/IAM/latest/APIReference/
  #
  # All requests are POST and always through HTTPS. Use the third parameter to
  # #initialize if you need to talk to a region other than us-east-1.
  ##
  class IAM < API
    endpoint "iam"
    use_https true
    version "2010-05-08"

    include CallTypes::ActionParam
  end

end
