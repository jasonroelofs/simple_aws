require 'simple_aws/api'
require 'simple_aws/call_types/action_param'
require 'simple_aws/signing/version2'

module SimpleAWS

  ##
  # Amazon's Import / Export
  #
  # http://docs.amazonwebservices.com/AWSImportExport/latest/API/Welcome.html
  #
  # All requests are POST and always through HTTPS.
  # This API does not support region specifiers.
  #
  # @see SimpleAWS::CallTypes::ActionParam Calling rules
  # @see SimpleAWS::Response Response handling
  ##
  class ImportExport < API
    endpoint "importexport"
    use_https true
    version "2010-06-03"

    def initialize(key, secret)
      super(key, secret)
    end

    include CallTypes::ActionParam
    include Signing::Version2
  end

end
