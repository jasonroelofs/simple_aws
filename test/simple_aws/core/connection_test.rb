require 'test_helper'
require 'simple_aws/core/request'
require 'simple_aws/core/response'
require 'simple_aws/core/connection'

describe SimpleAWS::Connection do

  describe "#call" do

    before do
      @connection = SimpleAWS::Connection.new
      @http_response = stub_everything(:success? => true, :parsed_response => {"value" => {}})
    end

    it "takes a basic request and runs it" do
      request = SimpleAWS::Request.new(:get, "host.com", "/")

      SimpleAWS::HTTP.expects(:get).with {|uri, options|
        uri.must_equal "host.com/"
      }.returns(@http_response)

      @connection.call request
    end

    it "returns the response wrapped in our Response object" do
      request = SimpleAWS::Request.new(:get, "host.com", "/")

      SimpleAWS::HTTP.expects(:get).returns(@http_response)

      response = @connection.call request
      response.must_be_kind_of SimpleAWS::Response
      response.body.must_equal "value" => {}
    end

    it "pulls parameters into the request" do
      request = SimpleAWS::Request.new(:get, "host.com", "/")
      request.params["Param1"] = "Something"

      SimpleAWS::HTTP.expects(:get).with {|uri, options|
        options[:query].wont_be_nil
        options[:query]["Param1"].must_equal "Something"
      }.returns(@http_response)

      @connection.call request
    end

    it "adds any headers from the Request object" do
      request = SimpleAWS::Request.new(:get, "host.com", "/")
      request.headers["Header"] = "Awesome"

      SimpleAWS::HTTP.expects(:get).with {|uri, options|
        options[:query].wont_be_nil
        options[:headers].must_equal "Header" => "Awesome"
      }.returns(@http_response)

      @connection.call request
    end

    it "passes through any body on the Request" do
      request = SimpleAWS::Request.new(:get, "host.com", "/")
      request.body = "This is some body text"

      SimpleAWS::HTTP.expects(:get).with {|uri, options|
        options[:query].wont_be_nil
        options[:body].must_equal "This is some body text"
      }.returns(@http_response)

      @connection.call request
    end

  end
end
