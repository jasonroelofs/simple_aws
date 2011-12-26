require 'aws/api'
require 'aws/call_types/action_param'

module AWS

  ##
  # Amazon's Elastic MapReduce
  #
  # http://docs.amazonwebservices.com/ElasticMapReduce/latest/API/
  #
  # All requests are POST and always through HTTPS. Use the third parameter to
  # #initialize if you need to talk to a region other than us-east-1.
  ##
  class MapReduce < API
    endpoint "elasticmapreduce"
    use_https true
    version "2009-03-31"

    include CallTypes::ActionParam
  end

end
