require 'simple_aws/api'
require 'simple_aws/call_types/action_param'
require 'simple_aws/signing/version3'

module SimpleAWS

  ##
  # Amazon's Simple Email Service
  #
  # http://docs.amazonwebservices.com/ses/latest/APIReference/
  #
  # All requests are POST and always through HTTPS.
  #
  # @see SimpleAWS::CallTypes::ActionParam Calling rules
  # @see SimpleAWS::Response Response handling
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
