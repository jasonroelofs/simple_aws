$: << File.expand_path("../../lib", __FILE__)

require 'aws/cloud_front'

##
# Expects your Amazon keys to be in the environment, something like
#
# export AWS_KEY="KEY"
# export AWS_SECRET="SECRET"
##

cloud_front = AWS::CloudFront.new ENV["AWS_KEY"], ENV["AWS_SECRET"]

puts "First ten distribution items:"

p cloud_front.get("/distribution", :params => {"MaxItems" => 10})

