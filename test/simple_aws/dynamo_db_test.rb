require 'test_helper'
require 'simple_aws/dynamo_db'

describe SimpleAWS::DynamoDB do

  before do
    @api = SimpleAWS::DynamoDB.new "key", "secret"
  end

  it "points to the endpoint" do
    @api.uri.must_equal "https://dynamodb.us-east-1.amazonaws.com"
  end

  it "properly builds region endpoints" do
    api = SimpleAWS::DynamoDB.new "key", "secret", "eu-west-1"
    api.uri.must_equal "https://dynamodb.eu-west-1.amazonaws.com"
  end

  it "works with the current version" do
    @api.version.must_equal "2011-12-05"
  end

  describe "API calls" do

    it "requires a security token as the first parameter and add it as a header" do
      SimpleAWS::Connection.any_instance.expects(:call).with do |request|
        header = request.headers["x-amz-security-token"]
        header.must_equal "securitytoken"
        true
      end

      obj = SimpleAWS::DynamoDB.new "key", "secret"
      obj.create_table "securitytoken", {}
    end

    it "errors out if not given the right arguments" do
      obj = SimpleAWS::DynamoDB.new "key", "secret"

      lambda {
        obj.create_table
      }.must_raise ArgumentError
    end

    it "adds the requested action as x-amz-target header" do
      SimpleAWS::Connection.any_instance.expects(:call).with do |request|
        header = request.headers["x-amz-target"]
        header.must_equal "DynamoDB_20111205.CreateTable"
        true
      end

      obj = SimpleAWS::DynamoDB.new "key", "secret"
      obj.create_table "securitytoken", {}
    end

    it "adds the json content type header" do
      SimpleAWS::Connection.any_instance.expects(:call).with do |request|
        header = request.headers["Content-Type"]
        header.must_equal "application/x-amz-json-1.0"
        true
      end

      obj = SimpleAWS::DynamoDB.new "key", "secret"
      obj.create_table "securitytoken", {}
    end

    it "takes any body and serializes into JSON" do
      table_schema = {
        "TableName" => "Table1", "KeySchema" => {
          "HashKeyElement" => {"AttributeName" => "AttributeName1", "AttributeType" => "S"}
        }
      }

      SimpleAWS::Connection.any_instance.expects(:call).with do |request|
        request.body.wont_be_nil
        MultiJson.decode(request.body).must_equal table_schema
        true
      end

      obj = SimpleAWS::DynamoDB.new "key", "secret"
      obj.create_table "security_token", table_schema
    end

    it "takes a string body and forwards it off raw" do
      SimpleAWS::Connection.any_instance.expects(:call).with do |request|
        request.body.wont_be_nil
        request.body.must_equal %|{"string":"body"}|
        true
      end

      obj = SimpleAWS::DynamoDB.new "key", "secret"
      obj.create_table "security_token", %|{"string":"body"}|
    end

    it "builds and signs the request" do
      SimpleAWS::Connection.any_instance.expects(:call).with do |request|
        header = request.headers["x-amzn-authorization"]
        header.must_match(/^AWS3 /)
        header.must_match(/AWSAccessKeyId=key/)

        Time.parse(request.headers["x-amz-date"]).wont_be_nil
        true
      end

      obj = SimpleAWS::DynamoDB.new "key", "secret"
      obj.create_table "security_token", {}
    end

  end
end
