require 'aws/api'

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
      request = AWS::Request.new method, self.uri, "/#{self.version}#{path}"

      (options[:params] || {}).each do |k, v|
        request.params[k] = v
      end

      (options[:headers] || {}).each do |k, v|
        request.headers[k] = v
      end

      request.body = options[:body]

      connection = AWS::Connection.new
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
