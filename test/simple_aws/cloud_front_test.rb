require 'test_helper'
require 'simple_aws/cloud_front'

describe SimpleAWS::CloudFront do

  before do
    @api = SimpleAWS::CloudFront.new "key", "secret"
  end

  it "points to the endpoint" do
    @api.uri.must_equal "https://cloudfront.amazonaws.com"
  end

  it "does not support region selection" do
    lambda {
      SimpleAWS::CloudFront.new "key", "secret", "us-east-1"
    }.must_raise ArgumentError
  end

  describe "API calls" do

    [:get, :post, :put, :delete].each do |method|
      it "supports the #{method} HTTP method" do
        SimpleAWS::Connection.any_instance.expects(:call).with do |request|
          request.method.must_equal method
          true
        end

        @api.send method, "/"
      end
    end

    it "pre-pends the version to the path for every request" do
      SimpleAWS::Connection.any_instance.expects(:call).with do |request|
        request.path.must_equal "/2014-05-31/"
        true
      end

      @api.get "/"
    end

    it "takes parameters" do
      SimpleAWS::Connection.any_instance.expects(:call).with do |request|
        request.params["Parameter1"].must_equal "Value2"
        true
      end

      @api.get "/", :params => { "Parameter1" => "Value2" }
    end

    it "takes a raw body" do
      SimpleAWS::Connection.any_instance.expects(:call).with do |request|
        request.body.must_equal "This is a body of text"
        true
      end

      @api.get "/", :body => "This is a body of text"
    end

    it "uses :xml to take a hash and build XML from it" do
      SimpleAWS::Connection.any_instance.expects(:call).with do |request|
        request.headers["Content-Type"].must_equal "text/xml"
        request.body.must_match(/amazonaws\.com\/doc\//)
        request.body.must_match(/<InnerNode>/)
        true
      end

      @api.get "/", :xml => {:RootNode => { :InnerNode => "Value" } }
    end

    it "complains if :xml doesn't contain a Hash" do
      error = lambda {
        @api.get "/", :xml => "not a hash"
      }.must_raise RuntimeError

      error.message.must_match /must be a Hash/
    end

    it "takes extra headers" do
      SimpleAWS::Connection.any_instance.expects(:call).with do |request|
        request.headers["Header14"].must_equal "Out to Lunch"
        true
      end

      @api.get "/", :headers => { "Header14" => "Out to Lunch" }
    end

    it "signs the given request according to Version 3 rules" do
      SimpleAWS::Connection.any_instance.expects(:call).with do |request|
        request.headers["Authorization"].wont_be_nil
        header = request.headers["Authorization"]
        parts = header.split(":")

        parts[0].must_equal "AWS key"
        parts[1].wont_be_nil

        Time.parse(request.headers["Date"]).wont_be_nil
        true
      end.returns

      @api.get "/"
    end
  end

end
