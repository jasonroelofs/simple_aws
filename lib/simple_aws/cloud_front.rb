require 'simple_aws/api'
require 'simple_aws/core/util'

module SimpleAWS

  ##
  # Amazon's CloudFront
  #
  # http://docs.amazonwebservices.com/AmazonCloudFront/latest/APIReference/Welcome.html
  #
  # As CloudFront is much closer to a RESTful service than the other AWS APIs, all
  # calls through this API are done through these four HTTP methods:
  # GET, PUT, DELETE, and POST.
  #
  # The paths for all request get the version prepended on to them, you do not
  # have to worry about that part of the path. Outside of this, in keeping with
  # the goals of SimpleAWS, everything else should be exactly as you read it in
  # the AWS API docs in the link above.
  #
  # So "GET Distribution List" is
  #
  #     cloud_front.get "/distribution"
  #
  # For requests that need extra parameters, use the :params option
  #
  #     cloud_front.get "/distribution", :params => {
  #       "MaxItems" => 10
  #     }
  #
  # Like :params, use :headers to add headers to the request
  #
  #     cloud_front.get "/distribution", :headers => {
  #       "x-amz-security-token" => "security string"
  #     }
  #
  # The details of CloudFront requests are all passed through XML bodies.
  # To make this as simple and painless as possible, this API supports the
  # :xml option to turn a Hash into an XML string
  #
  #     cloud_front.post "/distribution", :xml => {
  #       :DistributionConfig => {
  #         ...
  #       }
  #     }
  #
  # Do note that this XML building is very simple, does not support attributes,
  # and will only work on Hashes, Arrays, and objects that can be easily `to_s`-ed.
  # Anything else will error out or might result in invalid request bodies.
  #
  # If you already have the XML string and just need to give it to the
  # request, you can use :body to set the raw value of the request body:
  #
  #     cloud_front.post "/distribution", :body => raw_body_xml
  #
  # All responses are wrapped in a SimpleAWS::Response object.
  ##
  class CloudFront < API
    endpoint "cloudfront"
    use_https true
    version "2014-05-31"

    def initialize(key, secret)
      super(key, secret)
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
    # Execute an HTTP request against CloudFront.
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
      request = SimpleAWS::Request.new method, self.uri, "/#{self.version}#{path}"

      (options[:params] || {}).each do |k, v|
        request.params[k] = v
      end

      (options[:headers] || {}).each do |k, v|
        request.headers[k] = v
      end

      if xml = options[:xml]
        raise ":xml must be a Hash" unless xml.is_a?(Hash)

        namespace = "http://cloudfront.amazonaws.com/doc/#{self.version}"
        request.body = SimpleAWS::Util.build_xml_from xml, namespace
        request.headers["Content-Type"] = "text/xml"
      else
        request.body = options[:body]
      end

      connection = SimpleAWS::Connection.new self
      connection.call finish_and_sign_request(request)
    end

    protected

    ##
    # Build and sign the final request, as per the rules here:
    # http://docs.amazonwebservices.com/AmazonCloudFront/latest/DeveloperGuide/RESTAuthentication.html
    ##
    def finish_and_sign_request(request)
      request.headers["Date"] = Time.now.utc.httpdate
      request.headers["Authorization"] =
        "AWS #{self.access_key}:#{Base64.encode64(build_signature_for(request)).chomp}"

      request
    end

    def build_signature_for(request)
      date = request.headers["x-amz-date"] || request.headers["Date"]

      OpenSSL::HMAC.digest("sha1", self.secret_key, date)
    end
  end
end
