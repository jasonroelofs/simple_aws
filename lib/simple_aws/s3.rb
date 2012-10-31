require 'simple_aws/api'

module SimpleAWS

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
  #     s3.get "/"
  #
  # When working with a specific bucket, pass in :bucket after the path:
  #
  #     s3.get "/", :bucket => "bucket_name"
  #
  #     s3.get "/?policy", :bucket => "bucket_name"
  #
  # For requests that need extra parameters, use the :params option:
  #
  #     s3.get "/object/name", :bucket => "bucket_name", :params => {
  #       "response-content-disposition" => "attachment"
  #     }
  #
  # Also use params in the cases that AWS asks for form fields, such as
  # "POST Object".
  #
  # A lot of S3 communication happens through request and response headers.
  # To specify a certian set of headers on the request, use :headers:
  #
  #     s3.get "/", :bucket => "bucket_name", :headers => {
  #       "x-amz-security-token" => "security string"
  #     }
  #
  # Many of the PUT requests require a body of some sort, sometimes XML,
  # sometimes JSON, and other times the raw file data. Use :body for this
  # information. :body is expected to be either a String containing the XML or
  # JSON information, or an object that otherwise response to #read for file
  # uploads. This API does not build XML or JSON for you right now.
  #
  #     s3.put "/object/name.txt", :bucket => "bucket_name", :body => File.open()
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
  # which parts to download next. You can see an example of this in samples/s3_batch_download.rb.
  #
  # Quality of Life note: if you forget the leading / (forward slash) in the path
  # of a resource when# working with a bucket, this library will catch the omission and
  # fix the path for you. Thus, the following is also a valid call:
  #
  #     s3.put "object/name.txt", :bucket => "bucket_name", :body => File.open()
  #
  # Raw file data in a response will be available in the #body method on the Response
  # returned by the method call.
  ##
  class S3 < API
    endpoint "s3"
    use_https true
    version "2006-03-01"

    ##
    # Build a full URL for the resource at +path+.
    #
    # @param path [String] The path of the resource that needs a URL
    # @param options [Hash] Options on how this URL will be generated.
    #
    #   If options includes +:expires+, this url will be a signed url. +:expires+
    #   needs to be the raw Unix timestamp at which this URL will expire, as
    #   defined in the S3 documentation.
    #
    #   Otherwise, +options+ can take anything as described above, but it
    #   will not use +:headers+ or anything related to +:body+.
    #
    # @return [String] The URL to the requested resource
    ##
    def url_for(path, options = {})
      request = build_request(:get, path, options)

      url = "#{self.uri}#{request.path}"
      sep = url =~ /\?/ ? "&" : "?"

      if request.params.any?
        params = request.params.map {|k, v| "#{k}=#{v}"}.join("&")
        url += "#{sep}#{params}"
        sep = "&"
      end

      if expires_at = options[:expires]
        # Small hack, expires is in the Date section of the
        # signing string, so we just do that here so that we don't
        # muddy up build_signature_for
        request.headers["Date"] = expires_at.to_i

        signature = "Signature=#{build_signature_for(request)}"
        key = "AWSAccessKeyId=#{self.access_key}"
        expires = "Expires=#{expires_at.to_i}"

        url += "#{sep}#{signature}&#{key}&#{expires}"
      end

      url
    end

    ##
    # Send a request using HTTP GET
    #
    # @param path [String] The path of the resource at hand
    # @param options [Hash] Options as defined above
    #
    # @return [SimpleAWS::Response] The results of the request
    #
    # @raise [SimpleAWS::UnsuccessfulResponse, SimpleAWS::UnknownErrorResponse] on response errors
    ##
    def get(path, options = {})
      call :get, path, options
    end

    ##
    # Send a request using HTTP POST
    #
    # @param path [String] The path of the resource at hand
    # @param options [Hash] Options as defined above
    #
    # @return [SimpleAWS::Response] The results of the request
    #
    # @raise [SimpleAWS::UnsuccessfulResponse, SimpleAWS::UnknownErrorResponse] on response errors
    ##
    def post(path, options = {})
      call :post, path, options
    end

    ##
    # Send a request using HTTP PUT
    #
    # @param path [String] The path of the resource at hand
    # @param options [Hash] Options as defined above
    #
    # @return [SimpleAWS::Response] The results of the request
    #
    # @raise [SimpleAWS::UnsuccessfulResponse, SimpleAWS::UnknownErrorResponse] on response errors
    ##
    def put(path, options = {})
      call :put, path, options
    end

    ##
    # Send a request using HTTP DELETE
    #
    # @param path [String] The path of the resource at hand
    # @param options [Hash] Options as defined above
    #
    # @return [SimpleAWS::Response] The results of the request
    #
    # @raise [SimpleAWS::UnsuccessfulResponse, SimpleAWS::UnknownErrorResponse] on response errors
    ##
    def delete(path, options = {})
      call :delete, path, options
    end

    ##
    # Send a request using HTTP HEAD
    #
    # @param path [String] The path of the resource at hand
    # @param options [Hash] Options as defined above
    #
    # @return [SimpleAWS::Response] The results of the request
    #
    # @raise [SimpleAWS::UnsuccessfulResponse, SimpleAWS::UnknownErrorResponse] on response errors
    ##
    def head(path, options = {})
      call :head, path, options
    end

    ##
    # Execute an HTTP request against S3.
    #
    # @param method [Symbol, String] The HTTP method to use
    # @param path [String] The path of the resource at hand
    # @param options [Hash] Options as defined above
    #
    # @return [SimpleAWS::Response] The results of the request
    #
    # @raise [SimpleAWS::UnsuccessfulResponse, SimpleAWS::UnknownErrorResponse] on response errors
    ##
    def call(method, path, options = {})
      request = self.build_request method, path, options

      connection = SimpleAWS::Connection.new self
      connection.call finish_and_sign_request(request)
    end

    ##
    # Build a request but do not send it. Helpful for debugging.
    #
    # @param method [Symbol, String] The HTTP method to use
    # @param path [String] The path of the resource at hand
    # @param options [Hash] Options as defined above
    #
    # @return [SimpleAWS::Request] Completed but not yet signed request object
    ##
    def build_request(method, path, options = {})
      if options[:bucket]
        path = "/#{options[:bucket]}/#{path}".gsub("//", "/")
      end

      request = SimpleAWS::Request.new method, self.uri, path

      (options[:params] || {}).each do |k, v|
        request.params[k] = v
      end

      (options[:headers] || {}).each do |k, v|
        request.headers[k] = v
      end

      if options[:file]
        options[:body] = options.delete(:file)
      end

      signing_params = {}
      request.params.delete_if {|k, v|
        if k =~ /^response-/i
          signing_params[k] = v
          true
        end
      }

      if signing_params.length > 0
        to_add = signing_params.map {|k, v|
          "#{k}=#{v}"
        }.join("&")

        request.path = request.path + "?#{to_add}"
      end

      request.body = options[:body]

      if request.body.respond_to?(:read)
        request.headers["Content-Type"] ||= "application/octet-stream"
        request.headers["Content-Length"] = File.size(request.body).to_s
        request.headers["Expect"] = "100-continue"
      end

      request
    end

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
        "AWS #{self.access_key}:#{build_signature_for(request)}"

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

      Base64.encode64(
        OpenSSL::HMAC.digest("sha1", self.secret_key, to_sign)
      ).chomp
    end

  end

end
