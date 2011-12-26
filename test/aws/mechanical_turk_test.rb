require 'test_helper'
require 'aws/mechanical_turk'

describe AWS::MechanicalTurk do

  before do
    @api = AWS::MechanicalTurk.new "key", "secret"
  end

  it "points to the endpoint" do
    @api.uri.must_equal "https://mechanicalturk.amazonaws.com"
  end

  it "works with the current version" do
    @api.version.must_equal "2011-10-01"
  end

  it "can be told to work in sandbox mode" do
    api = AWS::MechanicalTurk.new "key", "secret", true
    api.uri.must_equal "https://mechanicalturk.sandbox.amazonaws.com"
  end

  describe "API calls" do

    it "builds and signs calls with Operation and Service" do
      AWS::Connection.any_instance.expects(:call).with do |request|
        params = request.params
        params.wont_be_nil

        params["Operation"].must_equal "SearchHITs"
        params["Service"].must_equal "AWSMechanicalTurkRequester"
        params["AWSAccessKeyId"].must_equal "key"
        params["Version"].must_equal "2011-10-01"
        params["Signature"].wont_be_nil

        true
      end

      obj = AWS::MechanicalTurk.new "key", "secret"
      obj.SearchHITs
    end

  end
end
