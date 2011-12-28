require 'test_helper'
require 'aws/ses'

describe AWS::SES do

  before do
    @api = AWS::SES.new "key", "secret"
  end

  it "only works on one endpoint" do
    lambda {
      AWS::SES.new "key", "secret", "us-west-1"
    }.must_raise ArgumentError
  end

  it "points to the endpoint" do
    @api.uri.must_equal "https://email.us-east-1.amazonaws.com"
  end

  it "works with the current version" do
    @api.version.must_equal "2010-12-01"
  end

  describe "API calls" do

    it "builds and signs calls with Signature Version 3" do
      AWS::Connection.any_instance.expects(:call).with do |request|
        params = request.params
        params.wont_be_nil

        params["Action"].must_equal "SendEmail"
        request.headers["X-Amzn-Authorization"].wont_be_nil

        true
      end

      obj = AWS::SES.new "key", "secret"
      obj.send_email
    end

  end
end
