require 'test_helper'
require 'aws/api'

describe AWS::API do

  class TestAPI < AWS::API
  end

  describe ".endpoint" do
    it "allows definition of an endpoint for an API implementation" do
      TestAPI.endpoint "test-endpoint"
    end
  end

  describe ".default_region" do
    it "allows specification of a default endpoint" do
      TestAPI.default_region "us-west-1"
    end
  end

  describe ".use_https" do
    it "can be told to use HTTPS over HTTP" do
      TestAPI.use_https true
    end
  end

  describe ".version" do
    it "allows specifying version of the API" do
      TestAPI.version "2011-01-04"
    end
  end

  describe "#initialize" do
    it "takes AWS key and secret on construction" do
      obj = TestAPI.new "access_key", "secret_key"
      obj.access_key.must_equal "access_key"
      obj.secret_key.must_equal "secret_key"
    end

    it "can also take a region" do
      obj = TestAPI.new "access_key", "secret_key", "region"
      obj.region.must_equal "region"
    end

    it "makes version available" do
      TestAPI.version "2011-02-02"
      obj = TestAPI.new "access_key", "secret_key"
      obj.version.must_equal "2011-02-02"
    end
  end

  describe "#region" do
    it "uses default region if none given on constructor" do
      TestAPI.default_region "us-west-1"
      obj = TestAPI.new "access_key", "secret_key"

      obj.region.must_equal "us-west-1"
    end
  end

  describe "#uri" do
    before do
      TestAPI.endpoint nil
      TestAPI.default_region nil
      TestAPI.use_https nil
    end

    it "returns the full URI to the API endpoint in question" do
      TestAPI.endpoint "testing-endpoint"
      TestAPI.default_region nil

      obj = TestAPI.new "key", "secret"
      obj.uri.must_equal "http://testing-endpoint.amazonaws.com"
    end

    it "adds the region to the URI if specified in default_region" do
      TestAPI.endpoint "testing-endpoint"
      TestAPI.default_region "us-east-1"

      obj = TestAPI.new "key", "secret"
      obj.uri.must_equal "http://testing-endpoint.us-east-1.amazonaws.com"
    end

    it "adds the region to the URI if specified in constructor" do
      TestAPI.endpoint "testing-endpoint"
      TestAPI.default_region "us-east-1"

      obj = TestAPI.new "key", "secret", "eu-west-1"
      obj.uri.must_equal "http://testing-endpoint.eu-west-1.amazonaws.com"
    end

    it "uses http/https according to use_https" do
      TestAPI.endpoint "testing-endpoint"
      TestAPI.default_region nil
      TestAPI.use_https true

      obj = TestAPI.new "key", "secret"
      obj.uri.must_equal "https://testing-endpoint.amazonaws.com"
    end
  end
end
