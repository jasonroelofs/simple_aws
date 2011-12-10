require 'test_helper'
require 'aws/request'
require 'aws/connection'

describe AWS::Connection do

  it "takes an API object on construction" do
    conn = AWS::Connection.new "API"
    conn.api.must_equal "API"
  end

  describe "#call" do

    it "takes a Request and runs the appropriate request" do
      api = stub_everything
      api.stubs(:access_key).returns("access key")
      api.stubs(:secret_key).returns("secret key")
      api.stubs(:uri).returns("URL")
      api.stubs(:version).returns("2011-01-01")

      AWS::HTTP.expects(:post).with do |path, options|
        path.must_equal "URL"

        options[:body]["Action"].must_equal "request_action"
        options[:body]["Version"].must_equal "2011-01-01"
        options[:body]["AWSAccessKeyId"].must_equal "access key"
        options[:body]["SignatureMethod"].must_equal "HmacSHA256"
        options[:body]["SignatureVersion"].must_equal "2"

        options[:body]["Signature"].wont_be_nil

        Time.parse(options[:body]["Timestamp"]).wont_be_nil
        true
      end

      request = AWS::Request.new "request_action"

      conn = AWS::Connection.new api
      conn.call request
    end

  end
end
