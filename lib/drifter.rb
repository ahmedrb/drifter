require 'rubygems'
require 'drifter/distance/haversine'
require 'drifter/geocoders'
require 'drifter/location'

module Drifter

  @@default_geocoder = :google
  @@default_units = :miles
  @@last_error = nil


  # returns the default geocoder
  def self.default_geocoder
    @@default_geocoder
  end


  # Sets the default geocoder. Supported values are :google or :yahoo
  # If using :yahoo, you will also need to set your yahoo appid using
  # Drifter::Geocoders::Yahoo.app_id=()
  def self.default_geocoder=(value)
    @@default_geocoder = value
  end


  # Returns the default units for distance calculations
  def self.default_units
    @@default_units
  end


  # Sets the default units for distance calculations.
  # Supported values are :miles and :kms
  def self.default_units=(value)
    @@default_units=value
  end


  # Helper method to extract the lat and lng from an array or from any object
  # that responds to lat() and lng(). Returns nil if neither of those apply
  def self.extract_latlng(loc)
    return loc.first, loc.last if loc.is_a?(Array) && loc.size == 2
    return loc.lat, loc.lng if loc.respond_to?(:lat) && loc.respond_to?(:lng)
    return nil
  end


  # Same as Drifter,extract_latlng() but raises ArgumentError on failure
  def self.extract_latlng!(loc)
    lat, lng = extract_latlng(loc)
    return lat, lng if lat && lng
    raise ArgumentError, "Could not extract lat and lng from #{loc.class.name} object"
  end


  # Accepts a string or a set of coordinates and returns an Array of Drifter::Location
  # objects with the results of the geocoding request.  If there is an error, this
  # method returns nil and the error can be accessed via Drifter.last_error().
  #
  # You can over-ride the default geocoder using the params[:geocoder] option:
  # Drifter.geocode("somewhere", :geocoder => :yahoo)
  #
  # You can perform reverse geocoding by passing a [lat, lng] array, or an object that
  # responds to lat() and lng().  Any params besides :geocoder are url encoded
  # and sent to the geocoder as query string parameters.  This can be used to modify
  # the results of the query. See the README for an example.
  #
  # if location is a string containing an IP address, the :geocoder value is ignored
  # and the ip is geocoded using the hostip.info web service. This only returns a
  # country, city, lat and lng so you could reverse geocode the result to get more info
  def self.geocode(location, params={})
    geocoder = params.delete(:geocoder) || default_geocoder
    geocoder = :hostip if location.to_s =~ Drifter::Geocoders::HostIP::IP_PATTERN
    geocoder = case geocoder
      when :google then Drifter::Geocoders::Google
      when :yahoo then Drifter::Geocoders::Yahoo
      when :hostip then Drifter::Geocoders::HostIP
      else raise ArgumentError, "Geocoder #{geocoder} not recognised"
    end
    results = geocoder.geocode(location, params)
    @@last_error = geocoder.last_error
    return results
  end


  # Returns a Hash containing error code and status from a failed geocoding request
  def self.last_error
    @@last_error
  end

end
