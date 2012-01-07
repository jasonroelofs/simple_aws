require 'aws/core/util'

module AWS

  class UnsuccessfulResponse < RuntimeError
    attr_reader :code
    attr_reader :error_type
    attr_reader :error_message

    def initialize(code, error_type, error_message)
      super "#{error_type} (#{code}): #{error_message}"
      @code = code
      @error_type = error_type
      @error_message = error_message
    end
  end

  class UnknownErrorResponse < RuntimeError
    def initialize(body)
      super "Unable to parse error code from #{body.inspect}"
    end
  end

  ##
  # Wrapper object for all responses from AWS. This class gives
  # a lot of leeway to how you access the response object.
  # You can access the response directly through it's Hash representation,
  # which is a direct mapping from the raw XML returned from AWS.
  #
  # You can also use ruby methods. This object will convert those methods
  # in ruby_standard into appropriate keys (camelCase) and look for them
  # in the hash. This can be done at any depth.
  #
  # This class tries not to be too magical to ensure that
  # it never gets in the way. All nested objects are queryable like their
  # parents are, and all sets and arrays are found and accessible through
  # your typical Enumerable interface.
  #
  # The starting point of the Response querying will vary according to the structure
  # returned by the AWS API in question. For some APIs, like EC2, the response is
  # a relatively flat:
  #
  #  <DataRequestResponse>
  #    <requestId>...</requestId>
  #    <dataRequested>
  #      ...
  #    </dataRequested>
  #  </DataRequestResponse>
  #
  # In this case, your querying will start inside of <DataRequestResponse>, ala the first
  # method you'll probably call is +data_requested+. For other APIs, the response
  # object is a little deeper and looks like this:
  #
  #  <DataRequestResponse>
  #    <DataRequestedResult>
  #       <DataRequested>
  #          ...
  #       </DataRequested>
  #    </DataRequestedResult>
  #    <ResponseMetadata>
  #      <RequestId>...</RequestId>
  #    </ResponseMetadata>
  #  </DataRequestResponse>
  #
  # For these response structures, your query will start inside of <DataRequestedResult>,
  # ala your first method call will be +data_requested+. To get access to the request id of
  # both of these structures, simply use #request_id on the base response. You'll also
  # notice the case differences of the XML tags, this class tries to ensure that case doesn't
  # matter when you're querying with methods. If you're using raw hash access then yes the
  # case of the keys in question need to match.
  #
  # This class does ensure that any collection is always an Array, given that
  # when AWS returns a single item in a collection, the xml -> hash parser gives a
  # single hash back instead of an array. This class will also look for
  # array indicators from AWS, like <item> or <member> and squash them.
  #
  # If AWS returns an error code, instead of getting a Response back the library
  # will instead throw an UnsuccessfulResponse error with the pertinent information.
  ##
  class Response

    # Inner proxy class that handles converting ruby methods
    # into keys found in the underlying Hash.
    class ResponseProxy
      include Enumerable

      TO_SQUASH = %w(item member)

      def initialize(local_root)
        first_key = local_root.keys.first
        if local_root.keys.length == 1 && TO_SQUASH.include?(first_key)
          # Ensure squash key is ignored and it's children are always
          # turned into an array.
          @local_root = [local_root[first_key]].flatten.map do |entry|
            ResponseProxy.new entry
          end
        else
          @local_root = local_root
        end
      end

      def [](key_or_idx)
        value_or_proxy @local_root[key_or_idx]
      end

      ##
      # Get all keys at the current depth of the Response object.
      # This method will raise a NoMethodError if the current
      # depth is an array.
      ##
      def keys
        @local_root.keys
      end

      def length
        @local_root.length
      end

      def each(&block)
        @local_root.each(&block)
      end

      def method_missing(name, *args)
        if key = key_matching(name)
          value_or_proxy @local_root[key]
        else
          super
        end
      end

      protected

      def key_matching(name)
        return nil if @local_root.is_a? Array

        lower_base_aws_name = AWS::Util.camelcase name.to_s, :lower
        upper_base_aws_name = AWS::Util.camelcase name.to_s

        keys = @local_root.keys

        if keys.include? lower_base_aws_name
          lower_base_aws_name
        elsif keys.include? upper_base_aws_name
          upper_base_aws_name
        end
      end

      def value_or_proxy(value)
        case value
        when Hash
          ResponseProxy.new value
        when Array
          value.map {|v| ResponseProxy.new v }
        else
          value
        end
      end
    end

    ##
    # The raw parsed response body in Hash format
    ##
    attr_reader :body

    def initialize(http_response)
      if !http_response.success?
        error = parse_error_from http_response.parsed_response
        raise UnsuccessfulResponse.new(
          http_response.code,
          error["Code"],
          error["Message"]
        )
      end

      @body = http_response.parsed_response

      if @body
        inner = @body[@body.keys.first]
        response_root =
          if result_key = inner.keys.find {|k| k =~ /Result$/}
            inner[result_key]
          else
            inner
          end

        @request_root = ResponseProxy.new response_root
      end
    end

    ##
    # Direct access to the request body's hash.
    # This works on the first level down in the AWS response, bypassing
    # the root element of the returned XML so you can work directly in the
    # attributes that matter
    ##
    def [](key)
      @request_root[key]
    end

    ##
    # Delegate first-level method calls to the root Proxy object
    ##
    def method_missing(name, *args)
      @request_root.send(name, *args)
    end

    ##
    # Get the request ID from this response. Works on all known AWS response formats.
    # Some AWS APIs don't give a request id, such as CloudFront. For responses that
    # do not have a request id, this method returns nil.
    ##
    def request_id
      if metadata = @body[@body.keys.first]["ResponseMetadata"]
        metadata["RequestId"]
      elsif id = @body[@body.keys.first]["requestId"]
        id
      else
        nil
      end
    end

    protected

    def parse_error_from(body)
      if body.has_key? "ErrorResponse"
        body["ErrorResponse"]["Error"]
      elsif body.has_key? "Error"
        if body["Error"]["StringToSign"]
          body["Error"]["Message"] += " String to Sign: #{body["Error"]["StringToSign"].inspect}"
        end

        body["Error"]
      elsif body.has_key? "Response"
        body["Response"]["Errors"]["Error"]
      else
        raise UnknownErrorResponse.new body
      end
    end

  end

end
