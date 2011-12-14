module AWS

  ##
  # Defines all request information needed to run a request against an AWS API
  #
  # Requests need to know a number of attributes to work, including the host,
  # path, the HTTP method, and any params or POST bodies. Most of this is
  # straight forward through the constructor methods defined below. The one
  # special thing this class does is make it easier to work with AWS's
  # array and hash parameter syntax.
  #
  # Hashes, usually designated by +Attr.n.Name+ and +Attr.n.Value.m+ can
  # be sent to a Request as a normal Ruby hash like so:
  #
  #   request.params["Attr"] = {"key" => "value", "puppy" => "dog"}
  #
  # This class will ensure the keys and values get properly mapped into
  # the format AWS understands.
  #
  # Likewise with Arrays, which is the simpler +Attr.n+ designation, can
  # be given as straight ruby Arrays:
  #
  #   request.params["Attr"] = ["cat", "dog"]
  #
  # Everything else is straight forward HTTP-related setters and getters
  ##
  class Request

    class Params < Hash

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

    ##
    # HTTP method this Request will use (:get, :post, :put, :delete)
    ##
    attr_reader :method

    ##
    # Host and Path of the URI this Request will be using
    ##
    attr_reader :host, :path

    ##
    # Hash of parameters to pass in this Request. See top-level
    # documentation for any special handling of types
    ##
    attr_reader :params

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
