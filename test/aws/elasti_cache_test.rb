require 'test_helper'
require 'aws/elasti_cache'

describe AWS::ElastiCache do

  before do
    @api = AWS::ElastiCache.new "key", "secret"
  end

  it "points to elasticache, default to us-east-1" do
    @api.uri.must_equal "https://elasticache.us-east-1.amazonaws.com"
  end

  it "works with the current version" do
    @api.version.must_equal "2011-07-15"
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

      obj = AWS::ElastiCache.new "key", "secret"
      obj.describe_events
    end

  end
end
