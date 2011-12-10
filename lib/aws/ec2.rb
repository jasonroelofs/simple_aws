require 'aws/api'

module AWS

  class EC2 < API
    endpoint "ec2"
    use_https true
    version "2011-11-01"
  end

end
