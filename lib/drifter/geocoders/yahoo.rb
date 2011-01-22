require 'drifter/geocoders/base'
module Drifter
  module Geocoders

    # This class adds support for the Yahoo Placefinder API:
    # http://developer.yahoo.com/geo/placefinder/
    #
    # You must set your appid before using this geocoder:
    # Drifter::Geocoders::Yahoo.api_key = my_yahoo_appid
    class Yahoo < Drifter::Geocoders::Base

      YAHOO_BASE_URI = "http://where.yahooapis.com/geocode"
      @@api_key = nil


      # returns the API key (also known as appid) if set, or nil
      def self.api_key
        @@api_key
      end


      # sets the api key. Yahoo's API key is known as the appid and
      # is required for all calls to their Placefinder web service
      def self.api_key=(value)
        @@api_key = value
      end


      # nodoc
      def self.base_uri
        YAHOO_BASE_URI
      end


      # Geocodes 'location'.  Returns an array of Drifter::Location objects
      # To geocode a set of coordinates (known as reverse geocoding), you can
      # pass a two item array containing lat and lng or an object that responds
      # to lat() and lng(). Examples:
      #
      #
      #   >> Drifter::Geocoders::Yahoo.geocode("Manchester, UK")
      #   >> Drifter::Geocoders::Yahoo.geocode([52.555, -2.123])
      #   >> loc = SomeObject.new :lat => 52.555, :lng => -2.123
      #   >> Drifter::Geocoders::Yahoo.geocode(loc)
      #
      #
      # The returned Drifter::Location objects have the following attributes:
      #
      #   :address, :city, :state, :state_code, :country, :country_code,
      #   :post_code, :lat, :lng
      #
      # Any additional data returned by the geocoder can be accessed via the
      # Location object's data() method
      #
      # You can also customise the type of data Yahoo returns by
      # modifying the 'flags' parameter . e.g if 'flags' contains a T, yahoo
      # also returns a 'timezone' attribute for the location:
      #
      #
      #   >> results = Drifter::Geocoders::Yahoo.geocode("Manchester, UK", :flags => "T")
      #   >> results.first.data["timezone"]
      #   => "Europe/London"
      #
      # Yahoo supports other parameters and flags too, see their docs for more details.
      # http://developer.yahoo.com/geo/placefinder/guide/requests.html
      def self.geocode(location, params={})

        # set defaults and build the query
        params[:location] = location
        params[:flags] ||= 'J'

        # reverse geocoding?
        lat, lng = Drifter.extract_latlng(location)
        if lat && lng
          params[:location] = [lat, lng].join(',')
          params[:gflags] = params[:gflags].to_s + 'R'
        end

        check_flags_parameter!(params)
        uri = query_uri(params)
        response = fetch(uri)

        # set @@last_error and return nil on error
        doc = JSON.parse(response)
        if doc["ResultSet"]["Error"] != 0
          @@last_error = {
            :code => doc["ResultSet"]["Error"],
            :message => doc["ResultSet"]["ErrorMessage"]
          }
          return nil
        end

        # successful so clear any previous errors
        @@last_error = nil

        # check for results
        return [] if doc["ResultSet"]["Found"] == 0

        # build and return an array of Drifter::Location objects
        doc["ResultSet"]["Results"].collect do |result|
          loc = Drifter::Location.new

          # add all the standard attributes
          lines = [result["line1"], result["line2"], result["line3"], result["line4"]]
          lines.delete_if { |line| line.empty? }
          loc.address = lines.join(', ')

          loc.city = result["city"]
          loc.state = result["state"]
          loc.state_code = result["statecode"]
          loc.country = result["country"]
          loc.country_code = result["countrycode"]
          loc.post_code = result["postal"]
          loc.lat = result["latitude"]
          loc.lng = result["longitude"]

          # each Location object can also access the raw data if required
          loc.raw_data = result
          loc.raw_data_format = :hash
          loc.geocoder = :yahoo
          loc
        end

      end


      # returns a URI object after checking that we have an appid and at least one location parameter.
      # any parameter that the Yahoo placefinder API supports can be passed in params
      def self.query_uri(params={})
        # check we have all required parameters
        check_api_key!
        uri = URI.parse(base_uri)
        uri.query = hash_to_query_string(params)
        return uri
      end


      private


      # raises ArgumentError if @@api_key is nil
      def self.check_api_key!
        return unless api_key.nil?
        raise ArgumentError, "API Key (yahoo's appid) is missing!\nPlease set it using #{name}.api_key"
      end


      # geocode() needs responses in JSON format.  If flags contains a P or doesn't
      # contain a J the response wont be JSON. This method fixes 'bad' flags
      def self.check_flags_parameter!(params)
        flags = params[:flags].to_s
        flags = flags.gsub(/p/i, '')
        flags << 'J' unless flags.index('J')
        params[:flags] = flags
      end


    end
  end
end
