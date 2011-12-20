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

$elb.describe_load_balancers.describe_load_balancers_result.load_balancer_descriptions.each do |elb|
  puts "Name: #{elb.load_balancer_name}"
  puts "HealthCheck: #{elb.health_check.inspect}"

  elb.listener_descriptions.each do |desc|
    l = desc.listener
    puts "Listener: #{l.protocol}:#{l.load_balancer_port} => #{l.instance_protocol}:#{l.instance_port}"
  end

  puts ""
end
