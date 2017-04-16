require 'test_helper'
require 'simple_aws/dynamo_db'

describe SimpleAWS::DynamoDB do

  before do
    creds = stub :session_token => "session_token",
      :access_key_id => "access_key_id",
      :secret_access_key => "secret_access_key"
    response = stub :credentials => creds

    SimpleAWS::STS.any_instance.stubs(:get_session_token).returns response

    @api = SimpleAWS::DynamoDB.new "key", "secret"
  end

  it "forwards keys to STS, saves session token and new AWS keys for use" do
    @api.sts.wont_be_nil
    @api.access_key.must_equal "access_key_id"
    @api.secret_key.must_equal "secret_access_key"
    @api.session_token.must_equal "session_token"
  end

  it "points to the endpoint" do
    @api.uri.must_equal "https://dynamodb.us-east-1.amazonaws.com"
  end

  it "properly builds region endpoints" do
    api = SimpleAWS::DynamoDB.new "key", "secret", "eu-west-1"
    api.uri.must_equal "https://dynamodb.eu-west-1.amazonaws.com"
  end

  describe "API calls" do

    it "requires a security token as the first parameter and add it as a header" do
      SimpleAWS::Connection.any_instance.expects(:call).with do |request|
        true
      end

      obj = SimpleAWS::DynamoDB.new "key", "secret"
      obj.create_table
    end

    it "adds the requested action as x-amz-target header" do
      SimpleAWS::Connection.any_instance.expects(:call).with do |request|
        header = request.headers["x-amz-target"]
        header.must_equal "DynamoDB_20120810.CreateTable"
        true
      end

      obj = SimpleAWS::DynamoDB.new "key", "secret"
      obj.create_table
    end

    it "adds the json content type header" do
      SimpleAWS::Connection.any_instance.expects(:call).with do |request|
        header = request.headers["Content-Type"]
        header.must_equal "application/x-amz-json-1.0"
        true
      end

      obj = SimpleAWS::DynamoDB.new "key", "secret"
      obj.create_table
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
      obj.create_table table_schema
    end

    it "takes a string body and forwards it off raw" do
      SimpleAWS::Connection.any_instance.expects(:call).with do |request|
        request.body.must_equal %|{"string":"body"}|
        true
      end

      obj = SimpleAWS::DynamoDB.new "key", "secret"
      obj.create_table %|{"string":"body"}|
    end

    it "builds and signs the request and adds the session token" do
      SimpleAWS::Connection.any_instance.expects(:call).with do |request|
        header = request.headers["x-amzn-authorization"]
        header.must_match(/^AWS3 /)
        header.must_match(/AWSAccessKeyId=access_key_id/)

        header = request.headers["x-amz-security-token"]
        header.must_equal "session_token"

        Time.parse(request.headers["x-amz-date"]).wont_be_nil
        true
      end

      obj = SimpleAWS::DynamoDB.new "key", "secret"
      obj.create_table
    end

  end
end
