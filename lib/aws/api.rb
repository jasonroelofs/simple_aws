require 'aws/util'
require 'aws/connection'
require 'aws/request'

module AWS

  ##
  # Base class for all endpoint handler classes.
  #
  # See the list of AWS Endpoints for the values to use when
  # implementing various APIs:
  #
  #   http://docs.amazonwebservices.com/general/latest/gr/index.html?rande.html
  ##
  class API
    class << self

      ##
      # Define the AWS endpoint for the API being wrapped.
      ##
      def endpoint(endpoint)
        @endpoint = endpoint
      end

      ##
      # Specify a default region for all requests for this API.
      # This region will be used if no region is given to the
      # constructor
      ##
      def default_region(region)
        @default_region = region
      end

      ##
      # Specify whether this API uses HTTPS for requests. If not set,
      # the system will use HTTP. Some API endpoints are not available under
      # HTTP and some are only HTTP.
      ##
      def use_https(value)
        @use_https = value
      end

      ##
      # Specify the AWS version of the API in question. This will be a date string.
      ##
      def version(version)
        @version = version
      end

    end

    attr_reader :access_key, :secret_key, :region, :version

    ##
    # Construct a new access object for the API in question.
    # +access_key+ and +secret_key+ are as defined in AWS security standards.
    # Use +region+ if you need to explicitly talk to a certain AWS region
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
    ##
    def uri
      return @uri if @uri

      @uri = @use_https ? "https" : "http"
      @uri += "://#{@endpoint}"
      @uri += ".#{@region}" if @region
      @uri += ".amazonaws.com"
      @uri
    end

    ##
    # For any undefined methods, try to convert them into valid AWS
    # actions and return the results
    ##
    def method_missing(name, *args)
      request = AWS::Request.new AWS::Util.camelcase(name.to_s)

      connection = AWS::Connection.new self
      connection.call request
    end
  end
end
