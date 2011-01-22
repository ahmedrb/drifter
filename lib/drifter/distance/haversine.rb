module Drifter
  module Distance
    class Haversine

      EarthRadiusInMiles = 3956
      EarthRadiusInKms = 6371
      RAD_PER_DEG = 0.017453293  #  PI/180


      # this method is from Landon Cox's haversine.rb (GNU Affero GPL v3):
      # http://www.esawdust.com/blog/gps/files/HaversineFormulaInRuby.html:
      # http://www.esawdust.com (Landon Cox)
      # http://www.esawdust.com/blog/businesscard/businesscard.html
      def self.between(point1, point2, options={})
        lat1, lon1 = Drifter.extract_latlng!(point1)
        lat2, lon2 = Drifter.extract_latlng!(point2)

        dlon = lon2 - lon1
        dlat = lat2 - lat1

        dlon_rad = dlon * RAD_PER_DEG 
        dlat_rad = dlat * RAD_PER_DEG

        lat1_rad = lat1 * RAD_PER_DEG
        lon1_rad = lon1 * RAD_PER_DEG

        lat2_rad = lat2 * RAD_PER_DEG
        lon2_rad = lon2 * RAD_PER_DEG

        a = (Math.sin(dlat_rad/2))**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * (Math.sin(dlon_rad/2))**2
        c = 2 * Math.atan2( Math.sqrt(a), Math.sqrt(1-a))

        units = options.delete(:units) || Drifter.default_units
        return EarthRadiusInKms * c if units == :km
        return EarthRadiusInMiles * c
      end


      # haversine sql based on http://code.google.com/apis/maps/articles/phpsqlsearch.html
      # you will need to add 'select' and 'AS distance' if required
      def self.to_postgresql(options)
        origin = options[:origin]
        lat, lng = Drifter.extract_latlng!(origin)
        lat_column = options[:lat_column] || :lat
        lng_column = options[:lng_column] || :lng
        units = options[:units] || Drifter.default_units
        multiplier = EarthRadiusInMiles
        multiplier = EarthRadiusInKms if units == :km

        postgres = <<-EOS
          #{multiplier} * ACOS(
            COS( RADIANS(#{lat}) ) *
            COS( RADIANS( #{lat_column} ) ) *
            COS( RADIANS( #{lng_column} ) -
            RADIANS(#{lng}) ) +
            SIN( RADIANS(#{lat}) ) *
            SIN( RADIANS( #{lat_column} ) )
          )
        EOS
      end

      # postgresql code seems to work fine fo sql
      def self.to_mysql(options)
        to_postgresql(options)
      end

    end
  end
end
