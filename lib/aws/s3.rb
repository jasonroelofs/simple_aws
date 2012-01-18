require 'aws/api'

module AWS

  ##
  # Amazon's Simple Storage Service
  #
  # http://docs.amazonwebservices.com/AmazonS3/latest/API/Welcome.html
  #
  # As S3 is much closer to a RESTful service than the other AWS APIs, all
  # calls through this API are done through these five handled HTTP METHODS:
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
  #   s3.put "/object/name.txt", :bucket => "bucket_name", :body => File.open()
  #
  # This API does ensure that file data is uploaded as efficiently as possible,
  # streaming file data from disc to AWS without blowing up memory. If the
  # Content-Type header is not specified, it will be defaulted to application/octet-stream
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

    [:get, :put, :delete, :head].each do |method|
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
        options[:body] = options.delete(:file)
      end

      request.body = options[:body]

      if request.body.respond_to?(:read)
        request.headers["Content-Type"] ||= "application/octet-stream"
        request.headers["Content-Length"] = request.body.size.to_s
        request.headers["Expect"] = "100-continue"
      end

      connection = AWS::Connection.new
      connection.call finish_and_sign_request(request)
    end

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

    protected

    ##
    # Build and sign the final request, as per the rules here:
    # http://docs.amazonwebservices.com/AmazonS3/latest/dev/RESTAuthentication.html
    ##
    def finish_and_sign_request(request)
      request.headers["Date"] = Time.now.utc.httpdate
      request.headers["Authorization"] =
        "AWS #{self.access_key}:#{Base64.encode64(build_signature_for(request)).chomp}"

      request
    end

    def build_signature_for(request)
      amazon_headers = request.headers.select {|k, v|
        k =~ /^x-amz/i
      }.map {|k, v|
        "#{k.downcase}:#{v}".chomp
      }

      to_sign = [
        request.method.to_s.upcase,
        request.headers["Content-Md5"] || "",
        request.headers["Content-Type"] || "",
        request.headers["Date"],
        amazon_headers,
        request.path
      ].flatten.join("\n")

      OpenSSL::HMAC.digest("sha1", self.secret_key, to_sign)
    end

  end

end
