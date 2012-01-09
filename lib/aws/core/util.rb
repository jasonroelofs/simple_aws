require 'ox'

module AWS
  ##
  # Collection of helper methods used in the library
  ##
  module Util

    ##
    # Simpler version of ActiveSupport's camelize
    ##
    def camelcase(string, lower_first_char = false)
      return string if string =~ /[A-Z]/

      if lower_first_char
        string[0,1].downcase + camelcase(string)[1..-1]
      else
        string.split(/_/).map{ |word| word.capitalize }.join('')
      end
    end


    # AWS URI escaping, as implemented by Fog
    def uri_escape(string)
      # Quick hack for already escaped string, don't escape again
      # I don't think any requests require a % in a parameter, but if
      # there is one I'll need to rethink this
      return string if string =~ /%/

      string.gsub(/([^a-zA-Z0-9_.\-~]+)/) {
        "%" + $1.unpack("H2" * $1.bytesize).join("%").upcase
      }
    end

    ##
    # Take a hash and build a simple XML string from
    # that Hash. This does not support properties on elements,
    # and is meant for request bodies like what CloudFront expects.
    #
    # The hash body can contain symbols, strings, arrays and hashes
    ##
    def build_xml_from(hash, namespace = nil)
      doc = Ox::Document.new(:version => 1.0, :standalone => true)

      root_key = hash.keys.first
      root = Ox::Element.new root_key
      root[:xmlns] = namespace if namespace

      doc << root

      build_body root, hash[root_key]

      %|<?xml version="1.0" encoding="UTF-8"?>#{Ox.dump doc}|
    end

    extend self

    protected

    def build_body(parent, hash)
      hash.each do |key, value|
        case value
        when Hash
          node = build_node(key)
          build_body node, value
          parent << node
        when Array
          value.each do |entry|
            build_body parent, {key => entry}
          end
        else
          parent << build_node(key, value)
        end
      end
    end

    def build_node(key, value = nil)
      child = Ox::Element.new key
      child << value if value
      child
    end
  end
end
