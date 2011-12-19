require 'test_helper'
require 'aws/api'
require 'aws/call_types/action_param'

describe AWS::CallTypes::ActionParam do

  class ActionParamTesting < AWS::API
    endpoint "aptest"
    version "2011-01-01"
    use_https true

    include AWS::CallTypes::ActionParam
  end

  it "builds and signs AWS requests on methods it doesn't know about" do
    AWS::Connection.any_instance.expects(:call).with do |request|
      request.method.must_equal :post
      request.uri.must_equal "https://aptest.amazonaws.com/"

      params = request.params
      params.wont_be_nil

      params["Action"].must_equal "DescribeInstances"
      params["Version"].must_equal "2011-01-01"
      params["AWSAccessKeyId"].must_equal "key"
      params["SignatureMethod"].must_equal "HmacSHA256"
      params["SignatureVersion"].must_equal "2"

      params["Signature"].wont_be_nil

      Time.parse(params["Timestamp"]).wont_be_nil
      true
    end.returns

    obj = ActionParamTesting.new "key", "secret"
    obj.describe_instances
  end

  it "takes a hash parameter and gives it to the request" do
    AWS::Connection.any_instance.expects(:call).with do |request|

      params = request.params
      params["ParamA"].must_equal 1
      params["ParamB"].must_equal "Death to Smoochy"

      true
    end.returns

    obj = ActionParamTesting.new "key", "secret"
    obj.describe_instances "ParamA" => 1, "ParamB" => "Death to Smoochy"
  end
end
