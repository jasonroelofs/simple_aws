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
  # Wrapper object for all responses from AWS. This class gives
  # a lot of leeway to how you access the response object.
  # You can access the response directly through it's Hash representation,
  # which is a direct mapping from the raw XML returned from AWS.
  #
  # You can also use ruby methods. This object will convert those methods
  # in ruby_standard into appropriate keys (camelCase) and look for them
  # in the hash. This can be done at any depth.
  #
  # One special case handled is the "Set" data types. If this class finds
  # a nested object with the "item" key, it will take care of the mapping so
  # that instead of writing
  #
  #   response.reservation_set.item.first.reservation_id (DescribeInstances)
  #
  # you'll be able to write the above like:
  #
  #   response.reservation.first.reservation_id
  #
  # Outside of this, this class tries not to be too magical to ensure that
  # it never gets in the way. All nested objects are queryable like their
  # parents are, and all sets and arrays are found and accessible through
  # your typical Enumerable interface.
  #
  # This class will also ensure that any Set is always an Array, given that
  # when AWS returns a single item in a set, the xml -> hash parser gives a
  # single hash back instead of an array.
  ##
  class Response

    # Inner proxy class that handles converting ruby methods
    # into keys found in the underlying Hash.
    class ResponseProxy
      include Enumerable

      def initialize(local_root)
        if local_root.keys == ["item"]
          # Ensure "item" is ignored and it's children are always
          # turned into an array.
          @local_root = [local_root["item"]].flatten.map do |entry|
            ResponseProxy.new(entry)
          end
        else
          @local_root = local_root
        end
      end

      def [](key_or_idx)
        value_or_proxy(@local_root[key_or_idx] || @local_root[key_or_idx + "Set"])
      end

      def length
        @local_root.length
      end

      def each(&block)
        @local_root.each(&block)
      end

      def method_missing(name, *args)
        if value = value_for_key_matching(name)
          value_or_proxy value
        else
          super
        end
      end

      protected

      def value_for_key_matching(name)
        base_aws_name = AWS::Util.camelcase name.to_s, :lower
        @local_root[base_aws_name] ||
          @local_root[base_aws_name + "Set"]
      end

      def value_or_proxy(value)
        if value.is_a?(Hash) || value.is_a?(Array)
          ResponseProxy.new value
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
        error = http_response.parsed_response["Response"]["Errors"]["Error"]
        raise UnsuccessfulResponse.new(
          http_response.code,
          error["Code"],
          error["Message"]
        )
      end

      @body = http_response.parsed_response

      @request_root = ResponseProxy.new @body[@body.keys.first]
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

  end

end
