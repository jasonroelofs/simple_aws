module AWS
  ##
  # Collection of helper methods used in the library
  ##
  module Util

    ##
    # Simpler version of ActiveSupport's camelize
    ##
    def self.camelcase(string, lower_first_char = false)
      if lower_first_char
        string[0].downcase + camelcase(string)[1..-1]
      else
        string.split(/_/).map{ |word| word.capitalize }.join('')
      end
    end

  end
end
