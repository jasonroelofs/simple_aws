require 'test_helper'
require 'simple_aws/mechanical_turk'

describe SimpleAWS::MechanicalTurk do

  before do
    @api = SimpleAWS::MechanicalTurk.new "key", "secret"
  end

  it "points to the endpoint" do
    @api.uri.must_equal "https://mechanicalturk.amazonaws.com"
  end

  it "can be told to work in sandbox mode" do
    api = SimpleAWS::MechanicalTurk.new "key", "secret", true
    api.uri.must_equal "https://mechanicalturk.sandbox.amazonaws.com"
  end

  describe "API calls" do

    it "builds and signs calls with Operation and Service" do
      SimpleAWS::Connection.any_instance.expects(:call).with do |request|
        params = request.params
        params.wont_be_nil

        params["Operation"].must_equal "SearchHITs"
        params["Service"].must_equal "AWSMechanicalTurkRequester"
        params["AWSAccessKeyId"].must_equal "key"
        params["Version"].must_equal "2014-06-15"
        params["Signature"].wont_be_nil

        true
      end

      obj = SimpleAWS::MechanicalTurk.new "key", "secret"
      obj.SearchHITs
    end

  end
end
