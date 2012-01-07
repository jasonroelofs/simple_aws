require 'test_helper'
require 'aws/s3'

describe AWS::S3 do

  before do
    @api = AWS::S3.new "key", "secret"
  end

  it "points to the endpoint" do
    @api.uri.must_equal "https://s3.amazonaws.com"
  end

  it "properly builds region endpoints" do
    api = AWS::S3.new "key", "secret", "us-west-1"
    api.uri.must_equal "https://s3-us-west-1.amazonaws.com"
  end

  it "works with the current version" do
    @api.version.must_equal "2006-03-01"
  end

  describe "API calls" do

    [:get, :post, :put, :delete, :head].each do |method|
      it "supports the #{method} HTTP method" do
        AWS::Connection.any_instance.expects(:call).with do |request|
          request.method.must_equal method
          request.host.must_equal "https://s3.amazonaws.com"
          request.path.must_equal "/"
          true
        end

        @api.send method, "/"
      end
    end

    it "rebuilds the host if :bucket given" do
      AWS::Connection.any_instance.expects(:call).with do |request|
        request.host.must_equal "https://bucket-name.s3.amazonaws.com"
        true
      end

      @api.get "/", :bucket => "bucket-name"
    end

    it "takes parameters" do
      AWS::Connection.any_instance.expects(:call).with do |request|
        request.params["Parameter1"].must_equal "Value2"
        true
      end

      @api.get "/", :params => { "Parameter1" => "Value2" }
    end

    it "takes extra headers" do
      AWS::Connection.any_instance.expects(:call).with do |request|
        request.headers["Header14"].must_equal "Out to Lunch"
        true
      end

      @api.get "/", :headers => { "Header14" => "Out to Lunch" }
    end

    it "takes a raw body" do
      AWS::Connection.any_instance.expects(:call).with do |request|
        request.body.must_equal "This is a body of text"
        true
      end

      @api.get "/", :body => "This is a body of text"
    end

    it "signs the request using the Authorization header" do
      AWS::Connection.any_instance.expects(:call).with do |request|
        request.headers["Authorization"].wont_be_nil
        true
      end

      @api.get "/"
    end
  end
end
