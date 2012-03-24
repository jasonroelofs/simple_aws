require 'simple_aws/core/util'
require 'simple_aws/core/connection'
require 'simple_aws/core/request'

module SimpleAWS

  ##
  # Base class for all AWS API wrappers.
  #
  # See the list of AWS Endpoints for the values to use when
  # implementing various APIs:
  #
  #   http://docs.amazonwebservices.com/general/latest/gr/index.html?rande.html
  #
  ##
  class API
    class << self

      ##
      # Define the AWS endpoint for the API being wrapped.
      #
      # @param endpoint [String] Subdomain endpoint for this API. E.g. "s3" for Amazon's S3
      ##
      def endpoint(endpoint)
        @endpoint = endpoint
      end

      ##
      # Specify a default region for all requests for this API.
      #
      # @param region [String] Specify the region this API defaults to
      ##
      def default_region(region)
        @default_region = region
      end

      ##
      # Specify whether this API uses HTTPS for requests. If not set,
      # the system will use HTTP. Some API endpoints are not available under
      # HTTP and some are only HTTP.
      #
      # @param value [Boolean] Set whether this API uses HTTPS by default or not
      ##
      def use_https(value)
        @use_https = value
      end

      ##
      # Specify the AWS version of the API in question.
      #
      # @param version [String] The version this API currently uses.
      ##
      def version(version)
        @version = version
      end

    end

    attr_reader :access_key, :secret_key, :region, :version

    ##
    # Construct a new access object for the API in question.
    #
    # @param access_key [String] Amazon access key
    # @param secret_key [String] Amazon secret key
    # @param region [String] Give a specific region to talk to
    ##
    def initialize(access_key, secret_key, region = nil)
      @access_key = access_key
      @secret_key = secret_key

      @region = region || self.class.instance_variable_get("@default_region")
      @endpoint = self.class.instance_variable_get("@endpoint")
      @use_https = self.class.instance_variable_get("@use_https")
      @version = self.class.instance_variable_get("@version")
    end

    ##
    # Get the full host name for the current API
    #
    # @return [String] Full URI for this API
    ##
    def uri
      return @uri if @uri

      @uri = @use_https ? "https" : "http"
      @uri += "://#{@endpoint}"
      @uri += ".#{@region}" if @region
      @uri += ".amazonaws.com"
      @uri
    end
  end
end
