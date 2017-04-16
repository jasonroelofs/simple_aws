require 'test_helper'
require 'simple_aws/s3'

describe SimpleAWS::S3 do

  before do
    @api = SimpleAWS::S3.new "key", "secret"
  end

  it "points to the endpoint" do
    @api.uri.must_equal "https://s3.amazonaws.com"
  end

  it "properly builds region endpoints" do
    api = SimpleAWS::S3.new "key", "secret", "us-west-1"
    api.uri.must_equal "https://s3-us-west-1.amazonaws.com"
  end

  describe "url_for" do

    it "can build an unsigned, regular URL for the requested path" do
      url = @api.url_for("/object", :bucket => "johnson")
      url.must_equal "https://s3.amazonaws.com/johnson/object"
    end

    it "can build a signed, expiring URL" do
      url = @api.url_for("/object", :bucket => "johnson", :expires => Time.now.to_i + 60)
      url.must_match %r[https://s3.amazonaws.com/johnson/object\?]
      url.must_match %r[Expires=#{Time.now.to_i + 60}]
      url.must_match %r[AWSAccessKeyId=key]
      url.must_match %r[Signature=]
    end

    it "adds parameters to the path" do
      url = @api.url_for("/object", :bucket => "johnson", :params => {"param1" => "14"})
      url.must_equal "https://s3.amazonaws.com/johnson/object?param1=14"
    end

    it "properly handles response- parameters" do
      url = @api.url_for("/object", :bucket => "johnson",
                         :params => {"response-content-type" => "text/xml"})
      url.must_equal "https://s3.amazonaws.com/johnson/object?response-content-type=text/xml"
    end

    it "combines parameters and signing params properly" do
      url = @api.url_for("/object", :bucket => "johnson",
                         :params => {"response-content-type" => "text/xml"},
                         :expires => Time.now.to_i
                        )
      url.must_match %r{/johnson/object\?response-content-type=text/xml&Signature=}
    end

  end

  describe "API calls" do

    [:get, :post, :put, :delete, :head].each do |method|
      it "supports the #{method} HTTP method" do
        SimpleAWS::Connection.any_instance.expects(:call).with do |request|
          request.method.must_equal method
          request.host.must_equal "https://s3.amazonaws.com"
          request.path.must_equal "/"
          true
        end

        @api.send method, "/"
      end
    end

    it "rebuilds the path if :bucket given" do
      SimpleAWS::Connection.any_instance.expects(:call).with do |request|
        request.path.must_equal "/bucket-name/"
        true
      end

      @api.get "/", :bucket => "bucket-name"
    end

    it "auto-fixes path names if not preceeded by a /" do
      SimpleAWS::Connection.any_instance.expects(:call).with do |request|
        request.path.must_equal "/bucket-name/object_name/that_thing.jpg"
        true
      end

      @api.get "object_name/that_thing.jpg", :bucket => "bucket-name"
    end

    it "takes parameters" do
      SimpleAWS::Connection.any_instance.expects(:call).with do |request|
        request.params["Parameter1"].must_equal "Value2"
        true
      end

      @api.get "/", :params => { "Parameter1" => "Value2" }
    end

    it "handles the special response- parameters" do
      SimpleAWS::Connection.any_instance.expects(:call).with do |request|
        request.path.must_equal "/?response-content-type=application/xml"
        request.params["response-content-type"].must_be_nil
        true
      end

      @api.get "/", :params => { "response-content-type" => "application/xml" }
    end

    it "takes extra headers" do
      SimpleAWS::Connection.any_instance.expects(:call).with do |request|
        request.headers["Header14"].must_equal "Out to Lunch"
        true
      end

      @api.get "/", :headers => { "Header14" => "Out to Lunch" }
    end

    it "takes a raw body" do
      SimpleAWS::Connection.any_instance.expects(:call).with do |request|
        request.body.must_equal "This is a body of text"
        true
      end

      @api.get "/", :body => "This is a body of text"
    end

    it "adds appropriate headers if the body has a file in it" do
      file = File.new("Gemfile")

      SimpleAWS::Connection.any_instance.expects(:call).with do |request|
        request.body.must_equal file

        request.headers["Content-Length"].must_equal File.size(file).to_s
        request.headers["Content-Type"].must_equal "application/octet-stream"
        request.headers["Expect"].must_equal "100-continue"
        true
      end

      @api.get "/", :body => file
    end

    it "calculates size of body that isn't a File (responds to read)" do
      raw_body = StringIO.new "raw data"

      SimpleAWS::Connection.any_instance.expects(:call).with do |request|
        request.headers["Content-Length"].must_equal "8"
        true
      end

      @api.get "/", :body => raw_body
    end

    it "uses previously set content type if given" do
      SimpleAWS::Connection.any_instance.expects(:call).with do |request|
        request.headers["Content-Type"].must_equal(
          "application/pdf"
        )
        true
      end

      @api.get "/", :body => File.new("Gemfile"),
        :headers => {"Content-Type" => "application/pdf"}
    end

    it "sets the default content-type on post / put if none explicitly given" do
      SimpleAWS::Connection.any_instance.expects(:call).with do |request|
        request.headers["Content-Type"].must_equal "application/x-www-form-urlencoded"
        true
      end

      @api.put "/", :body => "some random body"
    end

    it "signs the given request according to Version 3 rules" do
      SimpleAWS::Connection.any_instance.expects(:call).with do |request|
        header = request.headers["Authorization"]
        parts = header.split(":")

        parts[0].must_equal "AWS key"
        parts[1].wont_be_nil

        Time.parse(request.headers["Date"]).wont_be_nil
        true
      end.returns

      @api.get "/"
    end

  end
end
