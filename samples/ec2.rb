$: << File.expand_path("../../lib", __FILE__)

require 'simple_aws/ec2'

##
# Expects your Amazon keys to be in the environment, something like
#
# export AWS_KEY="KEY"
# export AWS_SECRET="SECRET"
##

ec2 = SimpleAWS::EC2.new ENV["AWS_KEY"], ENV["AWS_SECRET"]

puts "", "Standard Only Addresses", ""

ec2.describe_addresses("Filter" => {"Name" => "domain", "Value" => "standard"}).addresses_set.each do |address|
  puts "IP: #{address.public_ip}"
  puts "Instance ID: #{address.instance_id}"
  puts "Domain: #{address.domain}"
  puts ""
end

puts "", "VPC Only addresses", ""

ec2.describe_addresses("Filter" => {"Name" => "domain", "Value" => "vpc"}).addresses_set.each do |address|
  puts "IP: #{address.public_ip}"
  puts "Instance ID: #{address.instance_id}"
  puts "Domain: #{address.domain}"
  puts "Allocation ID: #{address.allocation_id}"
  puts "Association ID: #{address.association_id}"
  puts ""
end

puts "", "Ask for both explicitly", ""

ec2.describe_addresses("Filter" => {"Name" => "domain", "Value" => ["standard", "vpc"]}).addresses_set.each do |address|
  puts "IP: #{address.public_ip}"
  puts "Instance ID: #{address.instance_id}"
  puts "Domain: #{address.domain}"
  puts ""
end
