require 'test_helper'
require 'aws/sns'

describe AWS::SNS do

  before do
    @api = AWS::SNS.new "key", "secret"
  end

  it "points to endpoint, default to us-east-1" do
    @api.uri.must_equal "https://sns.us-east-1.amazonaws.com"
  end

  it "works with the current version" do
    @api.version.must_equal "2010-03-31"
  end

  describe "API calls" do

    it "builds and signs calls with ActionParam rules" do
      AWS::Connection.any_instance.expects(:call).with do |request|
        params = request.params
        params.wont_be_nil

        params["Action"].must_equal "ListTopics"
        params["Signature"].wont_be_nil

        true
      end

      obj = AWS::SNS.new "key", "secret"
      obj.list_topics
    end

  end
end
