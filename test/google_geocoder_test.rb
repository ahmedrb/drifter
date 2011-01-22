require File.dirname(__FILE__) + '/test_helper'

class GoogleGeocoderTest < Test::Unit::TestCase

  def setup
  end

  # google's raw data isn't a simple key => value hash of address attributes
  # so we have to do a little digging
  def attribute_matching(key, data, property=:long_name)
    data["address_components"].each do |comp|
      return comp[property.to_s] if comp["types"].include?(key)
    end
    return nil
  end

  # checks that the given Location object has the the expected values when Geocoded using google
  def assert_google_location(data, loc)
    assert_equal :google, loc.geocoder
    assert_equal :hash, loc.raw_data_format

    assert_equal attribute_matching("locality", data), loc.city
    assert_equal attribute_matching("administrative_area_level_1", data), loc.state
    assert_equal attribute_matching("postal_code", data), loc.post_code
    assert_equal attribute_matching("country", data, :short_name), loc.country_code
    assert_equal data["geometry"]["location"]["lat"], loc.lat
    assert_equal data["geometry"]["location"]["lng"], loc.lng
  end


  # nodoc
  def stub_response(response_file)
    response = open_web_response(response_file)
    rx = Regexp.new(Drifter::Geocoders::Google.base_uri)
    FakeWeb.register_uri(:get, rx, :body => response)

    results = Drifter::Geocoders::Google.geocode("springfield")
    data = JSON.parse(response)
    error = Drifter::Geocoders::Google.last_error

    return results, data, error
  end


  # nodoc
  def test_error
    results, data, error = stub_response('google_error')
    assert_nil results
    assert_equal data["status"], error[:message]
    assert_equal data["status"], error[:code]
  end


  # nodoc
  def test_success_with_no_results
    results, data, error = stub_response('google_no_results')
    assert_nil error
    assert results.is_a?(Array)
    assert results.empty?
  end


  # nodoc
  def test_success_with_one_result
    results, data, error = stub_response('google_one_result')
    assert_nil error
    assert results.is_a?(Array)
    assert_equal 1, results.size
    assert_google_location data["results"].first, results.first
  end


  # ndoc
  def test_success_with_many_results
    results, data, error = stub_response('google_many_results')
    assert_nil error
    assert results.is_a?(Array)
    assert_equal 10, results.size # this value not returned by google hence hardcoded
    results.each_with_index do |loc, i|
      loc_data = data["results"][i]
      assert_google_location loc_data, loc
    end
  end

end
