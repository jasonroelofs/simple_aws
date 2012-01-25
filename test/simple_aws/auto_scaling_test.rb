require 'test_helper'
require 'simple_aws/auto_scaling'

describe SimpleAWS::AutoScaling do

  before do
    @api = SimpleAWS::AutoScaling.new "key", "secret"
  end

  it "points to the endpoint" do
    @api.uri.must_equal "https://autoscaling.amazonaws.com"
  end

  it "works with the current version" do
    @api.version.must_equal "2011-01-01"
  end

  describe "API calls" do

    it "builds and signs calls with ActionParam rules" do
      SimpleAWS::Connection.any_instance.expects(:call).with do |request|
        params = request.params
        params.wont_be_nil

        params["Action"].must_equal "ExecutePolicy"
        params["Signature"].wont_be_nil

        true
      end

      obj = SimpleAWS::AutoScaling.new "key", "secret"
      obj.execute_policy
    end

  end
end
