$: << File.expand_path("../../lib", __FILE__)

require 'aws/s3'

##
# Expects your Amazon keys to be in the environment, something like
#
# export AWS_KEY="KEY"
# export AWS_SECRET="SECRET"
##

s3 = AWS::S3.new ENV["AWS_KEY"], ENV["AWS_SECRET"]

p s3.get "/"

