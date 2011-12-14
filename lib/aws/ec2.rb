require 'aws/api'

module AWS

  class EC2 < API
    endpoint "ec2"
    use_https true
    version "2011-11-01"

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
