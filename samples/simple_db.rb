$: << File.expand_path("../../lib", __FILE__)

require 'simple_aws/simple_db'

##
# Expects your Amazon keys to be in the environment, something like
#
# export AWS_KEY="KEY"
# export AWS_SECRET="SECRET"
##

sdb = SimpleAWS::SimpleDB.new ENV["AWS_KEY"], ENV["AWS_SECRET"]

puts "", "All Domains", ""

p sdb.list_domains
