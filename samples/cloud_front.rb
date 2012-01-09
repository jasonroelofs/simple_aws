$: << File.expand_path("../../lib", __FILE__)

require 'aws/cloud_front'

##
# Expects your Amazon keys to be in the environment, something like
#
# export AWS_KEY="KEY"
# export AWS_SECRET="SECRET"
##

cloud_front = AWS::CloudFront.new ENV["AWS_KEY"], ENV["AWS_SECRET"]

puts "First ten distribution items:", ""

cloud_front.get("/distribution", :params => {"MaxItems" => 10}).distribution_summary.each do |d|
  puts "ID: #{d.id}"
  puts "Domain: #{d.domain_name}"
  if d["CustomOrigin"]
    puts "Custom Origin: #{d.custom_origin.inspect}"
  elsif d["S3Origin"]
    puts "S3 Origin: #{d.s3_origin.inspect}"
  end
  puts "Status: #{d.status}"
  puts ""
end

# Leaving this commented out. It works, but you can't quickly
# delete the new distribution so you'll have to clean up manually
#
#puts "", "Creating new test distribution", ""
#
#response = cloud_front.post "/distribution", :xml => {
#  "DistributionConfig" => {
#    "CustomOrigin" => {
#      "DNSName" => "cnd.example.com",
#      "HTTPPort" => 80,
#      "OriginProtocolPolicy" => "http-only"
#    },
#    "CallerReference" => "simple_aws_testing_#{rand(100_000)}",
#    "Enabled" => false
#  }
#}
#
#p response
#
#id = response.id
#etag = response.headers["etag"]
#
#puts ""
#puts "Created distribution with id #{id} and etag #{etag}."
#puts "It's at domain #{response.domain_name}"
