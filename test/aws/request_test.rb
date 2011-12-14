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

  describe "hashes" do
    it "converts hash params to AWS param names" do
      @request.params["Filter"] = {
        "filter1" => "value1",
        "filter2" => "value14"
      }

      @request.params.must_equal({
        "Filter.1.Name" => "filter1",
        "Filter.1.Value.1" => "value1",
        "Filter.2.Name" => "filter2",
        "Filter.2.Value.1" => "value14"
      })
    end

    it "converst nested arrays inside of hashes appropriately" do
      @request.params["Filter"] = {
        "filter1" => ["value1", "value14"]
      }

      @request.params.must_equal({
        "Filter.1.Name" => "filter1",
        "Filter.1.Value.1" => "value1",
        "Filter.1.Value.2" => "value14"
      })
    end
  end

  describe "arrays" do
    it "converts array params to AWS param names" do
      @request.params["Filter"] = ["value1", "value2", "value3"]

      @request.params.must_equal({
        "Filter.1" => "value1",
        "Filter.2" => "value2",
        "Filter.3" => "value3"
      })
    end
  end
end
