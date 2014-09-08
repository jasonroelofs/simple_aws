require 'test_helper'
require 'simple_aws/ec2'

describe SimpleAWS::EC2 do

  before do
    @api = SimpleAWS::EC2.new "key", "secret"
  end

  it "points to the endpoint" do
    @api.uri.must_equal "https://ec2.amazonaws.com"
  end

  describe "API calls" do

    it "builds and signs calls with ActionParam rules" do
      SimpleAWS::Connection.any_instance.expects(:call).with do |request|
        params = request.params
        params.wont_be_nil

        params["Action"].must_equal "DescribeInstances"
        params["Signature"].wont_be_nil

        true
      end

      obj = SimpleAWS::EC2.new "key", "secret"
      obj.describe_instances
    end

  end
end
