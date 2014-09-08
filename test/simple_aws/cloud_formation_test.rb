require 'test_helper'
require 'simple_aws/cloud_formation'

describe SimpleAWS::CloudFormation do

  before do
    @api = SimpleAWS::CloudFormation.new "key", "secret"
  end

  it "points to endpoint, default to us-east-1" do
    @api.uri.must_equal "https://cloudformation.us-east-1.amazonaws.com"
  end

  describe "API calls" do

    it "builds and signs calls with ActionParam rules" do
      SimpleAWS::Connection.any_instance.expects(:call).with do |request|
        params = request.params
        params.wont_be_nil

        params["Action"].must_equal "DescribeStacks"
        params["Signature"].wont_be_nil

        true
      end

      obj = SimpleAWS::CloudFormation.new "key", "secret"
      obj.describe_stacks
    end

  end
end
