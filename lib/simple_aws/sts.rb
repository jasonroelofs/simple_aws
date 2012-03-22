require 'simple_aws/api'
require 'simple_aws/call_types/action_param'
require 'simple_aws/signing/version2'

module SimpleAWS

  ##
  # Amazon's Security Token Service
  #
  # http://docs.amazonwebservices.com/STS/latest/APIReference/Welcome.html
  #
  # All requests are POST and always through HTTPS.
  #
  # @see SimpleAWS::CallTypes::ActionParam Calling rules
  # @see SimpleAWS::Response Response handling
  ##
  class STS < API
    endpoint "sts"
    use_https true
    version "2011-06-15"

    # STS only has one HTTP endpoint
    def initialize(key, secret)
      super(key, secret)
    end

    include CallTypes::ActionParam
    include Signing::Version2
  end

end
