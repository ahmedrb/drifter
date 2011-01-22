require File.dirname(__FILE__) + '/test_helper'

class Widget
  include Drifter::Location::Locatable
  attr_accessor :lat, :lng
end


class LocatableTest < Test::Unit::TestCase

  def setup
    @widget = Widget.new
  end


  # nodoc
  def floats_equal?(f1, f2)
    f1.to_s == f2.to_s
  end


  # nodoc
  def test_location
    @widget.lat = 10
    @widget.lng = 20
    loc = @widget.location
    assert_equal 10, loc.lat
    assert_equal 20, loc.lng

    @widget.lat = nil
    @widget.lng = nil
    assert_equal nil, @widget.location.lat
    assert_equal nil, @widget.location.lng
  end


  # nodoc
  def test_location_setter
    loc = Drifter::Location.new
    loc.lat = 10
    loc.lng = 20
    @widget.location = loc
    assert_equal 10, @widget.lat
    assert_equal 20, @widget.lng

    @widget.location = nil
    assert_nil @widget.lat
    assert_nil @widget.lng

    @widget.location = [3,4]
    assert_equal 3, @widget.lat
    assert_equal 4, @widget.lng
  end


  def test_distance_to
    assert_raise(ArgumentError) { @widget.distance_to nil }
    assert_raise(ArgumentError) { @widget.distance_to "" }
    assert_raise(ArgumentError) { @widget.distance_to 1 }

    # london
    @widget.lat = 51.5001524
    @widget.lng = -0.1262362

    # manchester
    lat = 53.4807125
    lng = -2.2343765

    manchester = Widget.new
    manchester.lat = lat
    manchester.lng = lng

    distance_in_miles = 162.941138493485
    distance_in_km = 262.411019550554

    # pass an array, default units
    distance = @widget.distance_to [lat, lng]
    assert floats_equal?(distance_in_miles, distance)

    # location as array, units in miles
    distance = @widget.distance_to [lat, lng], :units => :miles
    assert floats_equal?(distance_in_miles, distance)

    # location as array, units in km
    distance = @widget.distance_to [lat, lng], :units => :km
    assert floats_equal?(distance_in_km, distance)

    # location as Locatable object, default units
    distance = @widget.distance_to manchester
    assert floats_equal?(distance_in_miles, distance)

    # location as Locatable object, units in miles
    distance = @widget.distance_to manchester, :units => :miles
    assert floats_equal?(distance_in_miles, distance)

    # location as Locatable object, units in km
    distance = @widget.distance_to manchester, :units => :km
    assert floats_equal?(distance_in_km, distance)
  end

end
