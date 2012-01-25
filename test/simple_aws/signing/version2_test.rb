require 'test_helper'
require 'simple_aws/api'
require 'simple_aws/call_types/action_param'
require 'simple_aws/signing/version2'

describe SimpleAWS::Signing::Version2 do

  class SigningTestAPI < SimpleAWS::API
    endpoint "aptest"
    version "2011-01-01"
    use_https true

    include SimpleAWS::CallTypes::ActionParam
    include SimpleAWS::Signing::Version2
  end

  it "signs the given request according to Version 2 rules" do
    SimpleAWS::Connection.any_instance.expects(:call).with do |request|
      params = request.params
      params.wont_be_nil

      params["Version"].must_equal "2011-01-01"
      params["AWSAccessKeyId"].must_equal "key"
      params["SignatureMethod"].must_equal "HmacSHA256"
      params["SignatureVersion"].must_equal "2"

      params["Signature"].wont_be_nil

      Time.parse(params["Timestamp"]).wont_be_nil
      true
    end.returns

    obj = SigningTestAPI.new "key", "secret"
    obj.describe_instances
  end

end
