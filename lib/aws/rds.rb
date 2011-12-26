require 'aws/api'
require 'aws/call_types/action_param'

module AWS

  ##
  # Amazon's Relational Database Service
  #
  # http://docs.amazonwebservices.com/AmazonRDS/latest/APIReference/
  #
  # All requests are POST and always through HTTPS. Use the third parameter to
  # #initialize if you need to talk to a region other than us-east-1.
  ##
  class RDS < API
    endpoint "rds"
    use_https true
    version "2011-04-01"

    include CallTypes::ActionParam
  end

end
