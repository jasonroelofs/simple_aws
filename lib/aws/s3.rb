require 'aws/api'
require 'aws/signing/authorization_header'

module AWS

  ##
  # Amazon's Simple Storage Service
  #
  # http://docs.amazonwebservices.com/AmazonS3/latest/API/Welcome.html
  #
  # As S3 is much closer to a RESTful service than the other AWS APIs, all
  # calls through this API are done through the four handled HTTP METHODS:
  # GET, PUT, DELETE, POST and HEAD. When sending a request, follow exactly what
  # is described in the AWS API docs in the link above.
  #
  # So "GET Service" is
  #
  #   s3.get "/"
  #
  # When working with a specific bucket, pass in :bucket after the path:
  #
  #   s3.get "/", :bucket => "bucket_name"
  #
  #   s3.get "/?policy", :bucket => "bucket_name"
  #
  # For requests that need extra parameters, use the :params option:
  #
  #   s3.get "/object/name", :bucket => "bucket_name", :params => {
  #     "response-content-disposition" => "attachment"
  #   }
  #
  # Also use params in the cases that AWS asks for form fields, such as
  # "POST Object".
  #
  # A lot of S3 communication happens through request and response headers.
  # To specify a certian set of headers on the request, use :headers:
  #
  #   s3.get "/", :bucket => "bucket_name", :headers => {
  #     "x-amz-security-token" => "security string"
  #   }
  #
  # Many of the PUT requests require a body of some sort, sometimes XML,
  # sometimes JSON, and other times the raw file data. Use :body for this
  # information. :body is expected to be either a String containing the XML or
  # JSON information, or an object that otherwise response to #read for file
  # uploads. This API does not build XML or JSON for you right now.
  #
  #   s3.put "/object/name.txt", :bucket => "bucket_name", :body => {:file => File.open()}
  #
  # As this is a common use case, if you don't have any more parameters to send
  # with the file being uploaded, just use :file.
  #
  #   s3.put "/object/name.txt", :bucket => "bucket_name", :file => File.open()
  #
  # This API does ensure that file data is uploaded as efficiently as possible,
  # streaming file data from disc to AWS without blowing up memory. All files are
  # uploading using multipart/form-data.
  #
  # NOTE: Like the other parts of SimpleAWS, this API does NOT try to make the
  # AWS API better, but simply provides a cleaner, easy to use API for Ruby.
  # As such, this API does not offer streaming downloads of file data from S3.
  # That is up to you to implement at this time, by running a HEAD to get
  # Content-Length then repeated GETs using the "Range:bytes" header to specify
  # which parts to download next.
  #
  # Raw file data in a response will be available in the #body method on the Response
  # returned by the method call.
  ##
  class S3 < API
    endpoint "s3"
    use_https true
    version "2006-03-01"

    [:get, :post, :put, :delete, :head].each do |method|
      define_method(method) do |*args|
        self.call method, *args
      end
    end

    def call(method, path, options = {})
      if options[:bucket]
        path = path.gsub(/^\//, "/#{options[:bucket]}/")
      end

      request = AWS::Request.new method, self.uri, path

      (options[:params] || {}).each do |k, v|
        request.params[k] = v
      end

      (options[:headers] || {}).each do |k, v|
        request.headers[k] = v
      end

      if options[:file]
        options[:body] = {:file => options[:file]}
      end

      request.body = options[:body]

      if request.body.is_a?(Hash) && request.body[:file]
        request.headers["Content-Type"] =
          "multipart/form-data; boundary=-----------RubyMultipartPost"
      end

      connection = AWS::Connection.new
      connection.call finish_and_sign_request(request)
    end

    include Signing::AuthorizationHeader

    ##
    # S3 handles region endpoints a little differently
    ##
    def uri
      return @uri if @uri

      @uri = @use_https ? "https" : "http"
      @uri += "://#{@endpoint}"
      @uri += "-#{@region}" if @region
      @uri += ".amazonaws.com"
      @uri
    end

  end

end
