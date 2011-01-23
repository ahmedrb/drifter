# classes including this module must repond to lat(), lat=(), lng() and lng=()
module Drifter
  class Location
    module Locatable


      # nodoc
      def distance_to(loc, options={})
        Drifter::Distance::Haversine.between(self, loc, options)
      end


    end
  end
end
