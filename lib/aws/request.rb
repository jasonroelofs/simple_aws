module AWS

  ##
  # Defines all request information needed to run a request against an AWS API
  ##
  class Request

    attr_reader :action, :params

    def initialize(action, params = {})
      @action = action
      @params = params
    end
  end
end
