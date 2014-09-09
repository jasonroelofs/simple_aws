require 'test_helper'
require 'simple_aws/api'
require 'simple_aws/call_types/action_param'
require 'simple_aws/signing/version3'

describe SimpleAWS::Signing::Version3 do

  class SigningV3TestAPI < SimpleAWS::API
    endpoint "aptest"
    version "2011-01-01"
    use_https true

    include SimpleAWS::CallTypes::ActionParam
    include SimpleAWS::Signing::Version3
  end

  it "signs the given request according to Version 3 rules" do
    SimpleAWS::Connection.any_instance.expects(:call).with do |request|
      params = request.params
      params.wont_be_nil

      header = request.headers["X-Amzn-Authorization"]
      parts = header.split(", ")

      parts[0].must_equal "AWS3-HTTPS AWSAccessKeyId=key"
      parts[1].must_equal "Algorithm=HmacSHA256"
      parts[2].must_match /Signature=.*/

      params["Version"].must_equal "2011-01-01"
      params["AWSAccessKeyId"].must_equal "key"

      Time.parse(params["Timestamp"]).wont_be_nil
      true
    end.returns

    obj = SigningV3TestAPI.new "key", "secret"
    obj.describe_instances
  end

end
