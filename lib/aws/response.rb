require 'aws/util'

module AWS

  class UnsuccessfulResponse < RuntimeError
    attr_reader :code
    attr_reader :error_type
    attr_reader :error_message

    def initialize(code, error_type, error_message)
      super("#{error_type} (#{code}): #{error_message}")
      @code = code
      @error_type = error_type
      @error_message = error_message
    end
  end

  ##
  # Wrapper object for all responses from AWS.
  ##
  class Response

    ##
    # The raw parsed response body in Hash format
    ##
    attr_reader :body

    def initialize(http_response)
      if !http_response.success?
        error = http_response.parsed_response["Response"]["Errors"]["Error"]
        raise UnsuccessfulResponse.new(
          http_response.code,
          error["Code"],
          error["Message"]
        )
      end

      @body = http_response.parsed_response

      @request_body = @body[@body.keys.first]
    end

    ##
    # Direct access to the request body's hash.
    # This works on the first level down in the AWS response, bypassing
    # the root element of the returned XML so you can work directly in the
    # attributes that matter
    ##
    def [](key)
      @request_body[key]
    end

    ##
    # Allow mapping of ruby-esque method calls to the parameters
    # in the response.
    ##
    def method_missing(name, *args)
      aws_name = AWS::Util.camelcase name.to_s, :lower
      if value = @request_body[aws_name]
        value
      else
        super
      end
    end

  end

end
