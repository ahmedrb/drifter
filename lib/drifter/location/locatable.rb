# classes including this module must repond to lat(), lat=(), lng() and lng=()
module Drifter
  class Location
    module Locatable


      # nodoc
      def distance_to(loc, options={})
        Drifter::Distance::Haversine.between(self, loc, options)
      end


      # returns an empty Drifter:;Location object with lat and lng
      def location
        loc = Drifter::Location.new
        loc.lat = lat
        loc.lng = lng
        return loc
      end


      # sets lat and lng on the receiver using value. value can be any 
      # object that responds to lat() and lng() or a two-item [lat,lng] Array
      # if value is nil, lat and lng are both set to nil
      def location=(value)
        lat, lng = nil, nil
        lat, lng = Drifter.extract_latlng!(value) unless value.nil?
        self.lat = lat
        self.lng = lng
        return value
      end

    end
  end
end
