require 'test_helper'
require 'simple_aws/api'
require 'simple_aws/call_types/action_param'

describe SimpleAWS::CallTypes::ActionParam do

  class ActionParamTesting < SimpleAWS::API
    endpoint "aptest"
    version "2011-01-01"
    use_https true

    include SimpleAWS::CallTypes::ActionParam

    #noop
    def finish_and_sign_request(request)
      request
    end
  end

  it "takes an unknown method call and turns it into a request" do
    SimpleAWS::Connection.any_instance.expects(:call).with do |request|
      params = request.params
      params["Action"].must_equal "DescribeInstances"

      true
    end.returns

    obj = ActionParamTesting.new "key", "secret"
    obj.describe_instances
  end

  it "takes a hash parameter and gives it to the request" do
    SimpleAWS::Connection.any_instance.expects(:call).with do |request|

      params = request.params
      params["ParamA"].must_equal 1
      params["ParamB"].must_equal "Death to Smoochy"

      true
    end.returns

    obj = ActionParamTesting.new "key", "secret"
    obj.describe_instances "ParamA" => 1, "ParamB" => "Death to Smoochy"
  end
end
