require File.dirname(__FILE__) + '/test_helper'

class LocationTest < Test::Unit::TestCase

  def setup
    @location = Drifter::Location.new
  end


  def test_data_method
    # should return nil if raw_data is nil
    @location.raw_data = nil
    assert_nil @location.data

    # should return a Hash if raw_data format is :hash
    expected = { "foo" => "bar" }
    @location.raw_data_format = :hash
    @location.raw_data = expected
    assert_equal expected, @location.data

    # should return a Hash if raw_data_format is :json
    @location.raw_data = expected.to_json
    @location.raw_data_format = :json
    assert_equal expected, @location.data
  end

end
