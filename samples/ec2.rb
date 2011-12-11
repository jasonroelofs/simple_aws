$: << File.expand_path("../../lib", __FILE__)

require 'aws/ec2'

##
# Expects your Amazon keys to be in the environment, something like
#
# export AWS_KEY="KEY"
# export AWS_SECRET="SECRET"
##

ec2 = AWS::EC2.new ENV["AWS_KEY"], ENV["AWS_SECRET"]

ec2.describe_addresses.addresses_set.each do |address|
  puts "IP: #{address.public_ip}"
  puts "Instance ID: #{address.instance_id}"
  puts "Domain: #{address.domain}"
  if address.domain == "vpc"
    puts "Allocation ID: #{address.allocation_id}"
    puts "Association ID: #{address.association_id}"
  end
  puts ""
end
