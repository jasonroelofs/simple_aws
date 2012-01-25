require 'test_helper'
require 'simple_aws/sqs'

describe SimpleAWS::SQS do

  before do
    @api = SimpleAWS::SQS.new "key", "secret"
  end

  it "points to the endpoint" do
    @api.uri.must_equal "https://sqs.us-east-1.amazonaws.com"
  end

  it "works with the current version" do
    @api.version.must_equal "2011-10-01"
  end

  describe "API calls" do

    it "builds and signs calls with ActionParam rules" do
      SimpleAWS::Connection.any_instance.expects(:call).with do |request|
        params = request.params
        params.wont_be_nil

        params["Action"].must_equal "ListQueues"
        params["Signature"].wont_be_nil

        true
      end

      obj = SimpleAWS::SQS.new "key", "secret"
      obj.list_queues
    end

    it "listens for the first parameter to be a queue URL and sets the path appropriately" do
      SimpleAWS::Connection.any_instance.expects(:call).with do |request|
        params = request.params
        params.wont_be_nil

        request.host.must_equal "sqs.us-west-1.amazonaws.com"
        request.path.must_equal "/1234567890/queue_name"

        params["MessageBody"].must_equal "This is a message body"

        true
      end

      obj = SimpleAWS::SQS.new "key", "secret"
      obj.send_message "http://sqs.us-west-1.amazonaws.com/1234567890/queue_name",
        "MessageBody" => "This is a message body"
    end

  end
end
