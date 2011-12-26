require 'test_helper'
require 'aws/rds'

describe AWS::RDS do

  before do
    @api = AWS::RDS.new "key", "secret"
  end

  it "points to the endpoint" do
    @api.uri.must_equal "https://rds.amazonaws.com"
  end

  it "works with the current version" do
    @api.version.must_equal "2011-04-01"
  end

  describe "API calls" do

    it "builds and signs calls with ActionParam rules" do
      AWS::Connection.any_instance.expects(:call).with do |request|
        params = request.params
        params.wont_be_nil

        params["Action"].must_equal "DescribeEvents"
        params["Signature"].wont_be_nil

        true
      end

      obj = AWS::RDS.new "key", "secret"
      obj.describe_events
    end

  end
end
