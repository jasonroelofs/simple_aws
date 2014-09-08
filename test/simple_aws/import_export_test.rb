require 'test_helper'
require 'simple_aws/import_export'

describe SimpleAWS::ImportExport do

  before do
    @api = SimpleAWS::ImportExport.new "key", "secret"
  end

  it "does not support region selection" do
    lambda {
      SimpleAWS::ImportExport.new "key", "secret", "us-east-1"
    }.must_raise ArgumentError
  end

  it "points to endpoint" do
    @api.uri.must_equal "https://importexport.amazonaws.com"
  end

  describe "API calls" do

    it "builds and signs calls with ActionParam rules" do
      SimpleAWS::Connection.any_instance.expects(:call).with do |request|
        params = request.params
        params.wont_be_nil

        params["Action"].must_equal "ListJobs"
        params["Signature"].wont_be_nil

        true
      end

      obj = SimpleAWS::ImportExport.new "key", "secret"
      obj.list_jobs
    end

  end
end
