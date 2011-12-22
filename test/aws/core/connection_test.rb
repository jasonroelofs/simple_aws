require 'test_helper'
require 'aws/core/request'
require 'aws/core/response'
require 'aws/core/connection'

describe AWS::Connection do

  describe "#call" do

    before do
      @connection = AWS::Connection.new
      @http_response = stub_everything(:success? => true, :parsed_response => {"value" => {}})
    end

    it "takes a basic request and runs it" do
      request = AWS::Request.new(:get, "host.com", "/")

      AWS::HTTP.expects(:get).with {|uri, options|
        uri.must_equal "host.com/"
      }.returns(@http_response)

      @connection.call request
    end

    it "returns the response wrapped in our Response object" do
      request = AWS::Request.new(:get, "host.com", "/")

      AWS::HTTP.expects(:get).returns(@http_response)

      response = @connection.call request
      response.must_be_kind_of AWS::Response
      response.body.must_equal "value" => {}
    end

    it "pulls parameters into the request" do
      request = AWS::Request.new(:get, "host.com", "/")
      request.params["Param1"] = "Something"

      AWS::HTTP.expects(:get).with {|uri, options|
        options[:query].wont_be_nil
        options[:query]["Param1"].must_equal "Something"
      }.returns(@http_response)

      @connection.call request
    end

    it "adds the POST body if one is requested"

  end
end
