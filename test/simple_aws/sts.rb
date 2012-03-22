require 'test_helper'
require 'simple_aws/sts'

describe SimpleAWS::STS do

  before do
    @api = SimpleAWS::STS.new "key", "secret"
  end

  it "points to the endpoint" do
    @api.uri.must_equal "https://sts.amazonaws.com"
  end

  it "only works on one endpoint" do
    lambda {
      SimpleAWS::STS.new "key", "secret", "us-west-1"
    }.must_raise ArgumentError
  end

  it "works with the current version" do
    @api.version.must_equal "2011-06-15"
  end

  describe "API calls" do

    it "builds and signs calls with ActionParam rules" do
      SimpleAWS::Connection.any_instance.expects(:call).with do |request|
        params = request.params
        params.wont_be_nil

        params["Action"].must_equal "GetSessionToken"
        params["Signature"].wont_be_nil

        true
      end

      obj = SimpleAWS::STS.new "key", "secret"
      obj.get_session_token
    end

  end
end
