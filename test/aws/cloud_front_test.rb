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
          request.path.must_equal "/"
          true
        end

        @api.send method, "/"
      end
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
