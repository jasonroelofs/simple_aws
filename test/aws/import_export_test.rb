require 'test_helper'
require 'aws/import_export'

describe AWS::ImportExport do

  before do
    @api = AWS::ImportExport.new "key", "secret"
  end

  it "does not support region selection" do
    lambda {
      AWS::ImportExport.new "key", "secret", "us-east-1"
    }.must_raise ArgumentError
  end

  it "points to endpoint" do
    @api.uri.must_equal "https://importexport.amazonaws.com"
  end

  it "works with the current version" do
    @api.version.must_equal "2010-06-03"
  end

  describe "API calls" do

    it "builds and signs calls with ActionParam rules" do
      AWS::Connection.any_instance.expects(:call).with do |request|
        params = request.params
        params.wont_be_nil

        params["Action"].must_equal "ListJobs"
        params["Signature"].wont_be_nil

        true
      end

      obj = AWS::ImportExport.new "key", "secret"
      obj.list_jobs
    end

  end
end
