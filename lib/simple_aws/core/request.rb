require 'date'
require 'time'

module SimpleAWS

  ##
  # Defines a request to an Amazon API.
  #
  # Requests need to know a number of attributes to work, including the host,
  # path, the HTTP method, and any params or POST bodies. Most of this is
  # straight forward through the constructor and setter methods defined below.
  #
  # One of the more interesting aspects of the AWS API are the indexed parameters.
  # These are the parameters in the document defined thusly:
  #
  #     Filter.n.Name
  #     Filter.n.Value.m
  #
  # This class has special handling to facilitate building these parameters
  # from regular Ruby Hashes and Arrays, but does not prevent you from specifying
  # these parameters exactly as defined. For the example above, here are the
  # ways you can set these parameters:
  #
  # By yourself, filling in the `n` and `m` as you need:
  #
  #     request.params.merge({
  #       "Filter.1.Name" => "domain",
  #       "Filter.1.Value" => "vpc",
  #       "Filter.2.Name" => "ids",
  #       "Filter.2.Value.1" => "i-1234",
  #       "Filter.2.Value.2" => "i-8902"
  #     })
  #
  # Or let Request handle the indexing and numbering for you:
  #
  #     request.params["Filter"] = [
  #       {"Name" => "domain", "Value" => "vpc"},
  #       {"Name" => "ids", "Value" => ["i-1234", "i-8902"]}
  #     ]
  #
  # Straight arrays are handled as well:
  #
  #     request.params["InstanceId"] = ["i-1234", "i-8970"]
  #
  # In an effort to make this library as transparent as possible when working
  # directly with the AWS API, the keys of the hashes must be the values
  # specified in the API, and the values must be Hashes and/or Arrays who contain
  # easily String-serializable keys and values.
  #
  # A more detailed example can be found in `test/simple_aws/request_test.rb` where you can
  # see how to use many levels of nesting to build your AWS request.
  ##
  class Request

    class Params < Hash

      def []=(key, value)
        case value
        when Array
          process_array key, value
        when Hash
          process_hash key, value
        when Time
          super(key, value.iso8601)
        when Date
          super(key, value.strftime("%Y-%m-%d"))
        else
          super
        end
      end

      protected

      def process_array(base_key, array_in)
        array_in.each_with_index do |entry, index|
          entry_key = "#{base_key}.#{index + 1}"
          case entry
          when Hash
            process_hash entry_key, entry
          else
            self[entry_key] = entry
          end
        end
      end

      def process_hash(base_key, entry)
        entry.each do |inner_key, inner_value|
          full_inner_key = "#{base_key}.#{inner_key}"
          case inner_value
          when Array
            process_array full_inner_key, inner_value
          else
            self[full_inner_key] = inner_value
          end
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
    # Hash of headers to send with the request
    ##
    attr_reader :headers

    ##
    # Raw string data to be put in the body of the request.
    # Body can also be an IO object (something that response to #read) and
    # if so the request will stream the file to the server.
    ##
    attr_accessor :body

    ##
    # Set up a new Request for the given +host+ and +path+ using the given
    # http +method+ (:get, :post, :put, :delete).
    ##
    def initialize(method, host, path)
      @method = method
      @host = host
      self.path = path
      @params = Params.new
      @headers = {}
    end

    ##
    # Build up the full URI
    ##
    def uri
      "#{host}#{path}"
    end

    ##
    # Set path, makes sure that the path is never
    # nil or an empty string
    ##
    def path=(value)
      @path = (value.nil? || value == "") ? "/" : value
    end

  end
end
