require 'aws/api'
require 'aws/signing/authorization_header'

module AWS

  ##
  # Amazon's CloudFront CDN
  #
  # http://docs.amazonwebservices.com/AmazonCloudFront/latest/APIReference/Welcome.html
  #
  ##
  class CloudFront < API
    endpoint "cloudfront"
    use_https true
    version "2010-11-01"

    def initialize(key, secret)
      super(key, secret)
    end

    [:get, :post, :put, :delete].each do |method|
      define_method(method) do |*args|
        self.call method, *args
      end
    end

    def call(method, path, options = {})
      request = AWS::Request.new method, self.uri, path

      connection = AWS::Connection.new
      connection.call finish_and_sign_request(request)
    end

    include Signing::AuthorizationHeader
  end
end
