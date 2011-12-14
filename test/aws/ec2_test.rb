require 'test_helper'
require 'aws/ec2'

describe AWS::EC2 do

  before do
    @api = AWS::EC2.new "key", "secret"
  end

  it "points to ec2" do
    @api.uri.must_equal "https://ec2.amazonaws.com"
  end

  it "works with the current version" do
    @api.version.must_equal "2011-11-01"
  end

  describe "API calls" do

    it "builds and signs AWS requests on methods it doesn't know about" do
      AWS::Connection.any_instance.expects(:call).with do |request|
        request.method.must_equal :post
        request.uri.must_equal "https://ec2.amazonaws.com/"

        params = request.params
        params.wont_be_nil

        params["Action"].must_equal "DescribeInstances"
        params["Version"].must_equal "2011-11-01"
        params["AWSAccessKeyId"].must_equal "key"
        params["SignatureMethod"].must_equal "HmacSHA256"
        params["SignatureVersion"].must_equal "2"

        params["Signature"].wont_be_nil

        Time.parse(params["Timestamp"]).wont_be_nil
        true
      end.returns

      obj = AWS::EC2.new "key", "secret"
      obj.describe_instances
    end

    it "takes a hash parameter and gives it to the request" do
      AWS::Connection.any_instance.expects(:call).with do |request|

        params = request.params
        params["ParamA"].must_equal "Kittens"
        params["ParamB"].must_equal "Death%20to%20Smoochy"

        true
      end.returns

      obj = AWS::EC2.new "key", "secret"
      obj.describe_instances "ParamA" => "Kittens", "ParamB" => "Death to Smoochy"
    end

  end

end
