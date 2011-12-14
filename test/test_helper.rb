require 'rubygems'
gem 'minitest'
require 'minitest/autorun'

require 'mocha_standalone'

class MiniTest::Unit::TestCase
  include Mocha::API

  def setup
    mocha_teardown
  end

  def teardown
    mocha_verify
  end
end
