require 'test_helper'
require 'simple_aws/simple_db'

describe SimpleAWS::SimpleDB do

  before do
    @api = SimpleAWS::SimpleDB.new "key", "secret"
  end

  it "points to the endpoint" do
    @api.uri.must_equal "https://sdb.amazonaws.com"
  end

  it "works with the current version" do
    @api.version.must_equal "2009-04-15"
  end

  describe "API calls" do

    it "builds and signs calls with ActionParam rules" do
      SimpleAWS::Connection.any_instance.expects(:call).with do |request|
        params = request.params
        params.wont_be_nil

        params["Action"].must_equal "ListDomains"
        params["Signature"].wont_be_nil

        true
      end

      obj = SimpleAWS::SimpleDB.new "key", "secret"
      obj.list_domains
    end

  end
end
