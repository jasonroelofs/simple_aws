require 'test_helper'
require 'aws/api'
require 'aws/call_types/action_param'
require 'aws/signing/authorization_header'

describe AWS::Signing::AuthorizationHeader do

  class SigningAuthHeaderTestAPI < AWS::API
    endpoint "aptest"
    version "2011-01-01"
    use_https true

    include AWS::CallTypes::ActionParam
    include AWS::Signing::AuthorizationHeader
  end

  it "signs the given request according to Version 3 rules" do
    AWS::Connection.any_instance.expects(:call).with do |request|
      header = request.headers["Authorization"]
      parts = header.split(":")

      parts[0].must_equal "AWS key"
      parts[1].wont_be_nil

      Time.parse(request.headers["Date"]).wont_be_nil
      true
    end.returns

    obj = SigningAuthHeaderTestAPI.new "key", "secret"
    obj.describe_instances
  end

end
