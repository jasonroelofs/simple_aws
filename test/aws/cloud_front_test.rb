require 'test_helper'
require 'aws/cloud_front'

describe AWS::CloudFront do

  before do
    @api = AWS::CloudFront.new "key", "secret"
  end

  it "points to the endpoint" do
    @api.uri.must_equal "https://cloudfront.amazonaws.com"
  end

  it "does not support region selection" do
    lambda {
      AWS::CloudFront.new "key", "secret", "us-east-1"
    }.must_raise ArgumentError
  end

  it "works with the current version" do
    @api.version.must_equal "2010-11-01"
  end

  describe "API calls" do

    [:get, :post, :put, :delete].each do |method|
      it "supports the #{method} HTTP method" do
        AWS::Connection.any_instance.expects(:call).with do |request|
          request.method.must_equal method
          true
        end

        @api.send method, "/"
      end
    end

    it "pre-pends the version to the path for every request" do
      AWS::Connection.any_instance.expects(:call).with do |request|
        request.path.must_equal "/2010-11-01/"
        true
      end

      @api.get "/"
    end

    it "signs the given request according to Version 3 rules" do
      AWS::Connection.any_instance.expects(:call).with do |request|
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
