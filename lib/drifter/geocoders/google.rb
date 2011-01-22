require 'drifter/geocoders/base'

module Drifter
  module Geocoders
    
    # This class adds support for Google's geocoding API:
    # http://code.google.com/apis/maps/documentation/geocoding/
    class Google < Drifter::Geocoders::Base

      GOOGLE_BASE_URI = 'http://maps.googleapis.com/maps/api/geocode/json'


      # nodoc
      def self.base_uri
        GOOGLE_BASE_URI
      end


      # This method works exactly like Drifter::Geocoders::Yahoo.geocode()
      # See that method for more info.  The returned Drifter::Location objects
      # have the following attributes:
      #
      #   :address, :city, :state, :state_code, :country, :country_code,
      #   :post_code, :lat, :lng
      #
      # Additional google specific attributes can be accessed using the Location
      # object's data() method
      def self.geocode(location, params={})

        params[:address] = location

        # check for reverse gecoding
        lat, lng = Drifter.extract_latlng(location)
        if lat && lng
          params.delete(:address)
          params[:latlng] = [lat, lng].join(',')
        end

        uri = query_uri(params)
        response = fetch(uri)

        # check for errors and return if necassary
        doc = JSON.parse(response)
        unless ["OK", "ZERO_RESULTS"].include?(doc["status"])
          @@last_error = { :code => doc["status"], :message => doc["status"] }
          return nil
        end

        # still here so safe to clear errors
        @@last_error = nil

        # is there anything to parse?
        return [] if doc["status"] == "ZERO_RESULTS"

        doc["results"].collect do |result|
          loc = Drifter::Location.new
          loc.raw_data_format = :hash
          loc.raw_data = result
          loc.geocoder = :google

          loc.address = result["formatted_address"]
          loc.lat = result["geometry"]["location"]["lat"]
          loc.lng = result["geometry"]["location"]["lng"]

          result["address_components"].each do |comp|
            loc.country_code = comp["short_name"] if comp["types"].include?("country")
            loc.country = comp["long_name"] if comp["types"].include?("country")
            loc.city = comp["long_name"] if comp["types"].include?("locality")
            loc.post_code = comp["long_name"] if comp["types"].include?("postal_code")
            loc.state = comp["long_name"] if comp["types"].include?("administrative_area_level_1")
            loc.state_code = comp["short_name"] if comp["types"].include?("administrative_area_level_1")
          end
          loc
        end

      end


      # Google requires a 'sensor' parameter. If none is set, it defaults to false
      # See their docs for more info
      def self.query_uri(params={})
        params[:sensor] ||= 'false'
        uri = URI.parse(base_uri)
        uri.query = hash_to_query_string(params)
        return uri
      end


    end
  end
end
