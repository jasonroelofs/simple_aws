require 'test_helper'
require 'aws/ec2'

describe AWS::EC2 do

  before do
    @api = AWS::EC2.new "key", "secret"
  end

  it "points to ec2" do
    @api.uri.must_equal "https://ec2.amazonaws.com"
  end

  it "works with the current version" do
    @api.version.must_equal "2011-11-01"
  end

  describe "API calls" do
    it "attempts to call AWS on method calls it doesn't know of" do
      AWS::Connection.any_instance.expects(:call).with do |request|
        request.action.must_equal "DescribeInstances"
        request.params.must_equal Hash.new
      end.returns

      obj = AWS::EC2.new "key", "secret"
      obj.describe_instances
    end

    it "takes a hash parameter and sends it to the request"
  end

end
