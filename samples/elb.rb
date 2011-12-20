$: << File.expand_path("../../lib", __FILE__)

require 'aws/elb'

##
# Expects your Amazon keys to be in the environment, something like
#
# export AWS_KEY="KEY"
# export AWS_SECRET="SECRET"
##

$elb = AWS::ELB.new ENV["AWS_KEY"], ENV["AWS_SECRET"]

puts "", "Your Load Balancers", ""

p $elb.describe_load_balancesr
