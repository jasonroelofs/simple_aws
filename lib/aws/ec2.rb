require 'aws/api'
require 'aws/call_types/action_param'
require 'aws/signing/version2'

module AWS

  ##
  # Amazon's Elastic Computing Cloud
  #
  # http://docs.amazonwebservices.com/AWSEC2/latest/APIReference/index.html
  #
  # All requests are POST and always through HTTPS. Use the third parameter to
  # #initialize if you need to talk to a region other than us-east-1.
  ##
  class EC2 < API
    endpoint "ec2"
    use_https true
    version "2011-11-01"

    include CallTypes::ActionParam
    include Signing::Version2
  end

end
