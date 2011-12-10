require 'test_helper'
require 'aws/request'
require 'aws/connection'

describe AWS::Connection do

  it "takes a URI on construction" do
    conn = AWS::Connection.new "uri"
    conn.uri.must_equal "uri"
  end

  describe "#call" do

    it "takes a Request and runs the appropriate request" do
      AWS::HTTP.expects(:get).with do |path, options|
        path.must_equal "URL"
        options[:query].must_equal "Action" => 'request_action'
      end

      request = AWS::Request.new "request_action"

      conn = AWS::Connection.new "URL"
      conn.call request
    end

  end
end
