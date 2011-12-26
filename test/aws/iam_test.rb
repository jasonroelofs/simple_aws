require 'test_helper'
require 'aws/iam'

describe AWS::IAM do

  before do
    @api = AWS::IAM.new "key", "secret"
  end

  it "points to the endpoint" do
    @api.uri.must_equal "https://iam.amazonaws.com"
  end

  it "works with the current version" do
    @api.version.must_equal "2010-05-08"
  end

  describe "API calls" do

    it "builds and signs calls with ActionParam rules" do
      AWS::Connection.any_instance.expects(:call).with do |request|
        params = request.params
        params.wont_be_nil

        params["Action"].must_equal "GetGroup"
        params["Signature"].wont_be_nil

        true
      end

      obj = AWS::IAM.new "key", "secret"
      obj.get_group
    end

  end
end
