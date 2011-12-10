$: << File.expand_path("../../lib", __FILE__)

require 'aws/ec2'

##
# Expects your Amazon keys to be in the environment, something like
#
# export AWS_KEY="KEY"
# export AWS_SECRET="SECRET"
##

ec2 = AWS::EC2.new ENV["AWS_KEY"], ENV["AWS_SECRET"]

p ec2.describe_instances

p ec2.describe_addresses
