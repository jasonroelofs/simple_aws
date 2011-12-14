module AWS

  ##
  # Defines all request information needed to run a request against an AWS API
  ##
  class Request

    ##
    # Proxy class that handles converting params as needed (say for the
    # Array (Attribute.1.member) or Hash syntax (Field.n.Value.m) so that
    # the params can be given in native Array or Hash formats and still be
    # properly sent to AWS
    ##
    class Params < Hash
      ##
      # Hijack [] to check for specific values before saving the results
      ##
      def []=(key, value)
        case value
        when Hash
          insert_hash key, value
        when Array
          insert_array key, value
        else
          super
        end
      end

      protected

      def insert_hash(base_key, hash)
        value_keys = hash.keys.sort

        value_keys.each_with_index do |value_key, index|
          self["#{base_key}.#{index + 1}.Name"] = value_key
          self["#{base_key}.#{index + 1}.Value"] = [hash[value_key]].flatten
        end
      end

      def insert_array(base_key, array)
        array.each_with_index do |entry, index|
          self["#{base_key}.#{index + 1}"] = entry
        end
      end
    end

    attr_reader :method, :host, :path, :params

    ##
    # Set up a new Request for the given +host+ and +path+ using the given
    # http +method+ (:get, :post, :put, :delete).
    ##
    def initialize(method, host, path)
      @method = method
      @host = host
      @path = path
      @params = Params.new
    end

    ##
    # Build up the full URI
    ##
    def uri
      "#{host}#{path}"
    end

  end
end
