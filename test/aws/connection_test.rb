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
      api.stubs(:uri).returns("URL")
      api.stubs(:version).returns("2011-01-01")

      AWS::HTTP.expects(:get).with do |path, options|
        path.must_equal "URL"

        options[:query]["Action"].must_equal "request_action"
        options[:query]["Version"].must_equal "2011-01-01"
        options[:query]["AWSAccessKeyId"].must_equal "access key"
        options[:query]["SignatureMethod"].must_equal "HmacSHA256"
        options[:query]["SignatureVersion"].must_equal "2"
        Time.parse(options[:query]["Timestamp"]).wont_be_nil
        true
      end

      request = AWS::Request.new "request_action"

      conn = AWS::Connection.new api
      conn.call request
    end

  end
end
