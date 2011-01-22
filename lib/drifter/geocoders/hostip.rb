require 'drifter/geocoders/base'
module Drifter
  module Geocoders

    # This class adds support for basic ip address geocoding using the
    # free API from hostip.info
    class HostIP < Drifter::Geocoders::Base

      @@lat_error = nil
      BASE_URI = 'http://api.hostip.info/get_html.php'
      IP_PATTERN = /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/


      # nodoc
      def self.base_uri
        BASE_URI
      end


      # geocodes the given IP address.
      #
      # On Success: returns an array with one Drifter::Location object
      # On Failure: returns an empty array
      # On Error:   returns nil. last_error() holds error information
      def self.geocode(ip, options={})

        # TODO: tests!
        
        # make sure it's an IP address
        unless ip.to_s =~ IP_PATTERN
          @@last_error = { :message => ip.to_s + " is not a valid IP address" }
          return nil
        end

        # the position param is needed for lat/lng
        options[:ip] = ip.to_s
        options[:position] = true
        uri = query_uri(options)

        # get the response, should be 5 lines (6 but one is blank)
        response = fetch(uri)
        response = response.to_s.split("\n").collect { |line| line.empty?? nil : line }
        response.compact!
        unless response.size == 5
          @@last_error = { :message => "HostIP returned a response that #{name} doesn't understand" }
          return nil
        end

        # still here so the errors can be cleared
        @@last_error = nil

        # however, hostip wont return an error response for bad queries.
        # It just returns blank values and XX as the country code.  Treat that a
        # a successful request with no results:
        return [] if response.first =~ /XX/

        # now we can start building the object
        loc = Drifter::Location.new

        # Country: UNITED KINGDOM (UK)
        data = response[0].split(': ').last.split(' (')
        loc.country = data.first
        loc.country_code = data.last.sub(')', '')
        
        # City: London
        data = response[1].split(': ').last
        loc.city = data

        # Latitude: 51.5
        data = response[2].split(': ').last
        loc.lat = data.to_f

        # Longitude: -0.1167
        data = response[3].split(': ').last
        loc.lng = data.to_f

        return [loc]
      end


      # nodoc
      def self.query_uri(params)
        uri = URI.parse(base_uri)
        uri.query = hash_to_query_string(params)
        return uri
      end


    end

  end
end
