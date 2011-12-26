$: << File.expand_path("../../lib", __FILE__)

require 'aws/mechanical_turk'

##
# Expects your Amazon keys to be in the environment, something like
#
# export AWS_KEY="KEY"
# export AWS_SECRET="SECRET"
##

turk = AWS::MechanicalTurk.new ENV["AWS_KEY"], ENV["AWS_SECRET"], true

p turk.SearchHITs
