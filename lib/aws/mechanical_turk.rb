require 'aws/api'
require 'aws/call_types/action_param'

module AWS

  ##
  # Amazon's Mechanical Turk
  #
  # http://docs.amazonwebservices.com/AWSEC2/latest/APIReference/index.html
  #
  # All requests are POST and always through HTTPS.
  # Instead of regions, this API supports normal and sandbox mode. Use the third
  # parameter of #initialize to specify sandbox mode.
  #
  # For a more fleshed out object API for interacting with MechanicalTurk, you should
  # give rturk a try here: https://github.com/mdp/rturk
  #
  # @see AWS::CallTypes::ActionParam Calling rules
  # @see AWS::Response Response handling
  ##
  class MechanicalTurk < API
    endpoint "mechanicalturk"
    use_https true
    version "2011-10-01"

    def initialize(key, secret, sandbox = false)
      super(key, secret, sandbox ? "sandbox" : nil)
    end

    include CallTypes::ActionParam

    protected

    # Sign the Turk request according to SignatureVersion 0 rules.
    #
    # As this is coming from CallTypes::ActionParam we need to fix
    # the Action param first thing.
    def finish_and_sign_request(request)
      request.params["Operation"] = request.params.delete("Action")

      request.params.merge!({
        "Service" => "AWSMechanicalTurkRequester",
        "AWSAccessKeyId" => self.access_key,
        "Timestamp" => Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ"),
        "Version" => self.version
      })

      request.params["Signature"] = Base64.encode64(sign_request(request.params.clone)).chomp

      request
    end

    def sign_request(params)
      to_sign = [params["Service"], params["Operation"], params["Timestamp"]].join ""
      OpenSSL::HMAC.digest("sha1", self.secret_key, to_sign)
    end

  end

end
