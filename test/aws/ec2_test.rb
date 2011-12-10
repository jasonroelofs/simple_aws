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

end
