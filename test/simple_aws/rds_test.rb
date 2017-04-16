require 'test_helper'
require 'simple_aws/rds'

describe SimpleAWS::RDS do

  before do
    @api = SimpleAWS::RDS.new "key", "secret"
  end

  it "points to the endpoint" do
    @api.uri.must_equal "https://rds.amazonaws.com"
  end

  describe "API calls" do

    it "builds and signs calls with ActionParam rules" do
      SimpleAWS::Connection.any_instance.expects(:call).with do |request|
        params = request.params
        params.wont_be_nil

        params["Action"].must_equal "DescribeEvents"
        params["Signature"].wont_be_nil

        true
      end

      obj = SimpleAWS::RDS.new "key", "secret"
      obj.describe_events
    end

  end
end
