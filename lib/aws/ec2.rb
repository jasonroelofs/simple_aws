require 'aws/api'

module AWS

  class EC2 < API
    endpoint "ec2"
    default_region "us-east-1"
  end

end
