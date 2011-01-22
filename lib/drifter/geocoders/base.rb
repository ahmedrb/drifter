require 'cgi'
require 'json'
require 'net/http'
require 'uri'

module Drifter
  module Geocoders

    # nodoc
    class Base

      @@last_error = nil # used by geocode()


      # takes a location parameter and returns an Array of Drifter::Location objects
      # with the results of the geocoding request.  If the geocoder returns an error,
      # this method should store the error in @@last_error and return nil.
      def self.geocode(*args)
        raise "Not implemented"
      end


      # Returns a Hash containing error information from the last geocoding request
      # or nil if there was no error. Subclasses should set @@last_error to nil
      # after every successful request
      def self.last_error
        @@last_error
      end


      # Returns a URI object used to make the call to the geocoding service.
      # Subclasses should implement checks for required parameters. See geocoder/yahoo.rb
      # for an example
      def self.query_uri(options={})
        raise "Not implemented"
      end


      private


      # wrapper for Net::HTTP.get
      def self.fetch(uri)
        Net::HTTP.get(uri.host, uri.request_uri)
      end


      # Converts hash to a url enoded query string
      def self.hash_to_query_string(hash)
        qs = hash.collect{ |k,v| k.to_s + '=' + CGI::escape(v.to_s) }
        qs.join('&')
      end

    end

  end
end
