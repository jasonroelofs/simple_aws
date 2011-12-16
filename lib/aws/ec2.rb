require 'aws/api'
require 'aws/util'

module AWS

  ##
  # Hook into Amazon's Elastic Computing Cloud
  #
  # Intended usage of this API is simple, just call the methods you want and give these
  # methods the parameters as defined in the official API documentation:
  #
  # http://docs.amazonwebservices.com/AWSEC2/latest/APIReference/index.html
  #
  # For example, to run a DescribeInstances call:
  #
  #   ec2 = AWS::EC2.new "access_key", "secret_key"
  #   response = ec2.describe_instances(
  #     "InstanceId" => ["i-12345", "i-23456"]
  #   )
  #
  # See AWS::Request for specific details on what hand-holding is done in
  # terms of passing Ruby types like Arrays or Hashes. You can always just
  # pass in raw AWS params, like so:
  #
  #   ec2 = AWS::EC2.new "access_key", "secret_key"
  #   response = ec2.describe_instances(
  #     "InstanceId.1" => "i-12345",
  #     "InstanceId.2" => "i-23456"
  #   )
  #
  # See AWS::Response for details on what you can do with the Response object.
  #
  # All requests are POST and always through HTTPS. Use the third parameter to
  # #initialize if you need to talk to a region other than us-east-1.
  ##
  class EC2 < API
    endpoint "ec2"
    use_https true
    version "2011-11-01"

    ##
    # For any undefined methods, try to convert them into valid AWS
    # actions and return the results
    ##
    def method_missing(name, *args)
      request = AWS::Request.new :post, self.uri, "/"
      request.params["Action"] = AWS::Util.camelcase(name.to_s)

      if args.any? && args.first.is_a?(Hash)
        args.first.each do |key, value|
          request.params[key] = value
        end
      end

      connection = AWS::Connection.new
      connection.call finish_and_sign_request(request)
    end

    protected

    ##
    # Build and sign the final request, as per the rules here:
    # http://docs.amazonwebservices.com/AWSEC2/latest/UserGuide/index.html?using-query-api.html
    ##
    def finish_and_sign_request(request)
      request.params.merge!({
        "AWSAccessKeyId" => self.access_key,
        "SignatureMethod" => "HmacSHA256",
        "SignatureVersion" => "2",
        "Timestamp" => Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ"),
        "Version" => self.version
      })

      request.params["Signature"] = Base64.encode64(sign_request(request.params.clone)).chomp

      request
    end

    def sign_request(params)
      list = params.map {|k, v| [k, Util.uri_escape(v.to_s)] }
      list.sort! do |a, b|
        if a[0] == "AWSAccessKeyId"
          -1
        else
          a[0] <=> b[0]
        end
      end

      host = self.uri.gsub(/^http[s]:\/\//,'')

      to_sign = "POST\n#{host}\n/\n#{list.map {|p| p.join("=") }.join("&")}"
      OpenSSL::HMAC.digest("sha256", self.secret_key, to_sign)
    end

  end

end
