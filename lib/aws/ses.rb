require 'aws/api'
require 'aws/call_types/action_param'
require 'aws/signing/version3'

module AWS

  ##
  # Amazon's Simple Email Service
  #
  # http://docs.amazonwebservices.com/ses/latest/APIReference/
  #
  # All requests are POST and always through HTTPS.
  #
  # @see AWS::CallTypes::ActionParam Calling rules
  # @see AWS::Response Response handling
  ##
  class SES < API
    endpoint "email"
    use_https true
    version "2010-12-01"
    default_region "us-east-1"

    # SES only has one HTTP endpoint
    def initialize(key, secret)
      super(key, secret)
    end

    include CallTypes::ActionParam
    include Signing::Version3
  end

end
