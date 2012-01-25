require 'test_helper'
require 'simple_aws/map_reduce'

describe SimpleAWS::MapReduce do

  before do
    @api = SimpleAWS::MapReduce.new "key", "secret"
  end

  it "points to the endpoint" do
    @api.uri.must_equal "https://elasticmapreduce.amazonaws.com"
  end

  it "works with the current version" do
    @api.version.must_equal "2009-03-31"
  end

  describe "API calls" do

    it "builds and signs calls with ActionParam rules" do
      SimpleAWS::Connection.any_instance.expects(:call).with do |request|
        params = request.params
        params.wont_be_nil

        params["Action"].must_equal "GetGroup"
        params["Signature"].wont_be_nil

        true
      end

      obj = SimpleAWS::MapReduce.new "key", "secret"
      obj.get_group
    end

  end
end
