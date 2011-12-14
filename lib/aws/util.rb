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
        string[0,1].downcase + camelcase(string)[1..-1]
      else
        string.split(/_/).map{ |word| word.capitalize }.join('')
      end
    end


    # AWS URI escaping, as implemented by Fog
    def self.uri_escape(string)
      # Quick hack for already escaped string, don't escape again
      # I don't think any requests require a % in a parameter, but if
      # there is one I'll need to rethink this
      return string if string =~ /%/

      string.gsub(/([^a-zA-Z0-9_.\-~]+)/) {
        "%" + $1.unpack("H2" * $1.bytesize).join("%").upcase
      }
    end

  end
end
