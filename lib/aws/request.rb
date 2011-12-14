module AWS

  ##
  # Defines all request information needed to run a request against an AWS API
  ##
  class Request

    attr_reader :method, :host, :path, :params

    ##
    # Set up a new Request for the given +host+ and +path+ using the given
    # http +method+ (:get, :post, :put, :delete).
    ##
    def initialize(method, host, path)
      @method = method
      @host = host
      @path = path
      @params = {}
    end

    ##
    # Build up the full URI
    ##
    def uri
      "#{host}#{path}"
    end

  end
end
