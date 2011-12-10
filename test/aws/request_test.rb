require 'test_helper'
require 'aws/request'

describe AWS::Request do

  it "takes an action" do
    request = AWS::Request.new "action"
    request.action.must_equal "action"
  end

  it "takes optional parameters as a hash" do
    request = AWS::Request.new "action", :param1 => true, :param2 => false
    request.params.must_equal :param1 => true, :param2 => false
  end
end
