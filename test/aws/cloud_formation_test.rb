require 'test_helper'
require 'aws/cloud_formation'

describe AWS::CloudFormation do

  before do
    @api = AWS::CloudFormation.new "key", "secret"
  end

  it "points to endpoint, default to us-east-1" do
    @api.uri.must_equal "https://cloudformation.us-east-1.amazonaws.com"
  end

  it "works with the current version" do
    @api.version.must_equal "2010-05-15"
  end

  describe "API calls" do

    it "builds and signs calls with ActionParam rules" do
      AWS::Connection.any_instance.expects(:call).with do |request|
        params = request.params
        params.wont_be_nil

        params["Action"].must_equal "DescribeStacks"
        params["Signature"].wont_be_nil

        true
      end

      obj = AWS::CloudFormation.new "key", "secret"
      obj.describe_stacks
    end

  end
end
