require 'test_helper'
require 'aws/elastic_beanstalk'

describe AWS::ElasticBeanstalk do

  before do
    @api = AWS::ElasticBeanstalk.new "key", "secret"
  end

  it "points to endpoint, default to us-east-1" do
    @api.uri.must_equal "https://elasticbeanstalk.us-east-1.amazonaws.com"
  end

  it "works with the current version" do
    @api.version.must_equal "2010-12-01"
  end

  describe "API calls" do

    it "builds and signs calls with ActionParam rules" do
      AWS::Connection.any_instance.expects(:call).with do |request|
        params = request.params
        params.wont_be_nil

        params["Action"].must_equal "DescribeApplications"
        params["Signature"].wont_be_nil

        true
      end

      obj = AWS::ElasticBeanstalk.new "key", "secret"
      obj.describe_applications
    end

  end
end
