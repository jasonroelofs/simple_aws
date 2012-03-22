require 'simple_aws/api'
require 'simple_aws/signing/version3'
require 'multi_json'

module SimpleAWS

  ##
  # Amazon's DynamoDB NoSQL store
  #
  # http://docs.amazonwebservices.com/amazondynamodb/latest/developerguide/Introduction.html
  #
  # All requests are POST and always through HTTPS. Use the third parameter to
  # #initialize if you need to talk to a region other than us-east-1.
  #
  # This module hooks up the `method_missing` functionality as described in the
  # README. To call methods on APIs including this module, simply call a method
  # with either the Ruby-fied name, or the full CamelCase name, and pass in
  # options required as the parameters.
  #
  # All API calls to DynamoDB require two parameters: security_token and request_body.
  # The security_token can be retrieved from SimpleAWS::STS#get_session_token, and
  # the request_body must be a hash with serializable data, or a raw String that will
  # be sent directly to Amazon.
  #
  # See samples/dynamo_db.rb for how to use STS and DynamoDB together.
  #
  # @see SimpleAWS::Response Response handling
  ##
  class DynamoDB < API
    endpoint "dynamodb"
    default_region "us-east-1"
    use_https true
    version "2011-12-05"

    def method_missing(name, *args)
      if args.length != 2
        raise ArgumentError.new "Required arguments: (security_token, request_body) got #{args.inspect}"
      end

      token, body = *args

      request = SimpleAWS::Request.new :post, self.uri, "/"
      target = "DynamoDB_#{self.version.gsub("-","")}"
      request.headers["Content-Type"] = "application/x-amz-json-1.0"

      request.headers["x-amz-target"] = "#{target}.#{SimpleAWS::Util.camelcase(name.to_s)}"
      request.headers["x-amz-date"] = Time.now.rfc822
      request.headers["x-amz-security-token"] = token

      request.body = body.is_a?(String) ? body : MultiJson.encode(body)

      request.headers["x-amzn-authorization"] =
        "AWS3 AWSAccessKeyId=#{self.access_key}," +
        "Algorithm=HmacSHA256," +
        "Signature=#{build_signature_for(request)}"

      connection = SimpleAWS::Connection.new
      connection.call request
    end

    protected

    def build_signature_for(request)
      amazon_headers = request.headers.select {|k, v|
        k =~ /^x-amz-/i
      }.map {|k, v|
        "#{k.downcase}:#{v}".chomp
      }.sort

      to_sign = [
        request.method.to_s.upcase,
        request.path,
        "",
        "host:#{URI.parse(request.host).host}",
        amazon_headers,
        "",
        request.body
      ].flatten.join("\n")

      digested = OpenSSL::Digest::SHA256.digest(to_sign)
      Base64.encode64(
        OpenSSL::HMAC.digest("sha256", self.secret_key, digested)
      ).chomp
    end

  end

end
