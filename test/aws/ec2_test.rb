require 'test_helper'
require 'aws/ec2'

describe AWS::EC2 do

  before do
    @api = AWS::EC2.new "key", "secret"
  end

  it "points to the endpoint" do
    @api.uri.must_equal "https://ec2.amazonaws.com"
  end

  it "works with the current version" do
    @api.version.must_equal "2011-11-01"
  end

  describe "API calls" do

    it "builds and signs calls with ActionParam rules" do
      AWS::Connection.any_instance.expects(:call).with do |request|
        params = request.params
        params.wont_be_nil

        params["Action"].must_equal "DescribeInstances"
        params["Signature"].wont_be_nil

        true
      end

      obj = AWS::EC2.new "key", "secret"
      obj.describe_instances
    end

  end
end
