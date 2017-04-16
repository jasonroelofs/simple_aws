require 'simple_aws/api'
require 'simple_aws/sts'
require 'multi_json'

module SimpleAWS

  ##
  # Amazon's DynamoDB NoSQL Store
  #
  # http://docs.amazonwebservices.com/amazondynamodb/latest/developerguide/Introduction.html
  #
  # All requests are POST and always through HTTPS. Use the third parameter to
  # `initialize` if you need to talk to a region other than us-east-1.
  #
  # This module hooks up the `method_missing` functionality as described in the
  # README. To call methods on APIs including this module, simply call a method
  # with either the Ruby-fied name, or the full CamelCase name, and pass in
  # options required as the parameters.
  #
  # As all API calls to DynamoDB require a session token header garnered through STS,
  # you don't have to worry about it. This API will take care of the STS hop and ensure
  # the proper credentials are passed into DynamoDB as needed.
  #
  # With that, the only parameter you need to pass into your API call directly is the
  # body of the request, which can be a Hash containing keys and values serializable
  # to JSON or a raw JSON string that will be sent directly to Amazon:
  #
  #     dynamo_db.delete_table "TableName" => "Table1"
  #
  #     dynamo_db.delete_table "{'TableName': 'Table1'}"
  #
  # Note: It is possible right now that if you have a single instance of this API
  # for a long period that the `session_token` will eventually expire. If this becomes
  # and issue please open an Issue on Github and I'll look at making this handling
  # more robust. You can always recreate a new instance of SimpleAWS::DynamoDB
  # to get new STS credentials as needed.
  #
  # @see SimpleAWS::Response Response handling
  ##
  class DynamoDB < API
    endpoint "dynamodb"
    default_region "us-east-1"
    use_https true
    version "2012-08-10"

    attr_reader :sts, :session_token

    ##
    # Initialize a new instance of this API, swapping out `access_key` and
    # `secret_key` with values from the Security Token Service (STS).
    # This also will grab and store the session_token value for use in
    # DynamoDB API calls.
    #
    # @see SimpleAWS::API#initialize
    ##
    def initialize(access_key, secret_key, region = nil)
      @sts = SimpleAWS::STS.new access_key, secret_key

      sts_response = @sts.get_session_token.credentials
      @session_token = sts_response.session_token

      super(sts_response.access_key_id, sts_response.secret_access_key, region)
    end

    def method_missing(name, *args)
      request = SimpleAWS::Request.new :post, self.uri, "/"
      target = "DynamoDB_#{self.version.gsub("-","")}"
      request.headers["Content-Type"] = "application/x-amz-json-1.0"

      request.headers["x-amz-target"] = "#{target}.#{SimpleAWS::Util.camelcase(name.to_s)}"
      request.headers["x-amz-date"] = Time.now.rfc822
      request.headers["x-amz-security-token"] = @session_token

      body = args.first || {}
      request.body = body.is_a?(String) ? body : MultiJson.encode(body)

      request.headers["x-amzn-authorization"] =
        "AWS3 AWSAccessKeyId=#{self.access_key}," +
        "Algorithm=HmacSHA256," +
        "Signature=#{build_signature_for(request)}"

      connection = SimpleAWS::Connection.new self
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
