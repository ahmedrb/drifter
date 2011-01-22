require File.dirname(__FILE__) + '/test_helper'

class YahooGeocoderTest < Test::Unit::TestCase

  def setup
    Drifter::Geocoders::Yahoo.api_key = "foo"
  end

  # checks that the given Location object has the the expected values when Geocoded using Yahoo
  def assert_yahoo_location(data, loc)
    assert_equal :yahoo, loc.geocoder
    assert_equal :hash, loc.raw_data_format
    assert_equal data["city"], loc.city
    assert_equal data["state"], loc.state
    assert_equal data["postal"], loc.post_code
    assert_equal data["countrycode"], loc.country_code
    assert_equal data["latitude"], loc.lat
    assert_equal data["longitude"], loc.lng
  end


  # nodoc
  def stub_response(response_file)
    response = open_web_response(response_file)
    rx = Regexp.new(Drifter::Geocoders::Yahoo.base_uri)
    FakeWeb.register_uri(:get, rx, :body => response)

    results = Drifter::Geocoders::Yahoo.geocode("springfield")
    data = JSON.parse(response)
    error = Drifter::Geocoders::Yahoo.last_error

    return results, data, error
  end


  # nodoc
  def test_error
    results, data, error = stub_response('yahoo_error')
    assert_nil results
    assert_equal data["ResultSet"]["ErrorMessage"], error[:message]
    assert_equal data["ResultSet"]["Error"], error[:code]
  end


  # nodoc
  def test_success_with_no_results
    results, data, error = stub_response('yahoo_no_results')
    assert_nil error
    assert results.is_a?(Array)
    assert results.empty?
  end


  # nodoc
  def test_success_with_one_result
    results, data, error = stub_response('yahoo_one_result')
    assert_nil error
    assert results.is_a?(Array)
    assert_equal 1, results.size
    assert_yahoo_location data["ResultSet"]["Results"].first, results.first
  end


  # ndoc
  def test_success_with_many_results
    results, data, error = stub_response('yahoo_many_results')
    assert_nil error
    assert results.is_a?(Array)
    assert_equal data["ResultSet"]["Found"], results.size
    results.each_with_index do |loc, i|
      loc_data = data["ResultSet"]["Results"][i]
      assert_yahoo_location loc_data, loc
    end
  end

end
