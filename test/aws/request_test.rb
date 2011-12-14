require 'test_helper'
require 'aws/request'

describe AWS::Request do

  before do
    @request = AWS::Request.new :get, "https://example.com", "/action"
  end

  it "is constructed with a method, host and path" do
    @request.wont_be_nil
  end

  it "builds full URI" do
    @request.uri.must_equal "https://example.com/action"
  end

  it "knows it's HTTP method" do
    @request.method.must_equal :get
  end

  it "can be given parameters to pass in" do
    @request.params["Param1"] = "Value1"
    @request.params["Param2"] = "Value2"

    @request.params.must_equal "Param1" => "Value1", "Param2" => "Value2"
  end
end
