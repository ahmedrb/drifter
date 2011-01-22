require 'drifter/location/locatable'
module Drifter
  # Drifter.geocode() returns an array of Drifter::Location objects
  # Depending on the geocoder used, Location objects are populated
  # with a bunch of common attributes - see the docs for individual
  # geocoders for a list of attributes they set:
  #
  # Drifter::Geocoders::Google.geocode()
  # Drifter::Geocoders::Yahoo.geocode()
  #
  # Additional data returned by the geocoder can be accessed via the
  # data() method
  class Location
    include Drifter::Location::Locatable

    attr_accessor :raw_data
    attr_accessor :raw_data_format
    attr_accessor :geocoder

    attr_accessor :address
    attr_accessor :city
    attr_accessor :state
    attr_accessor :state_code
    attr_accessor :post_code
    attr_accessor :country
    attr_accessor :country_code
    attr_accessor :lat
    attr_accessor :lng

    # returns a Hash containing the geocoder's raw data. This is geocoder
    # specific and you should read the provider's docs to see what data
    # they return in each geocoding response
    def data
      @data ||= case raw_data_format
        when :hash then return raw_data
        when :json then return JSON.parse(raw_data)
        else nil
      end
    end


  end
end
