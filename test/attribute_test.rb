# encoding: utf-8
require 'test_helper'
require 'active_support/inflector'
require 'oj'

class AttributeTest < Test::Unit::TestCase

  # --- Google ---

  def test_google_result_components
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "Manhattan",
      result.address_components_of_type(:sublocality).first['long_name']
  end

  def test_google_result_components_contains_route
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "Penn Plaza",
      result.address_components_of_type(:route).first['long_name']
  end

  def test_google_result_components_contains_street_number
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "4",
      result.address_components_of_type(:street_number).first['long_name']
  end

  def test_google_returns_city_when_no_locality_in_result
    result = Geocoder.search("no locality").first
    assert_equal "Haram", result.city
  end

  def test_google_city_results_returns_nil_if_no_matching_component_types
    result = Geocoder.search("no city data").first
    assert_equal nil, result.city
  end

  def test_google_street_address_returns_formatted_street_address
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "4 Penn Plaza", result.street_address
  end

  def test_google_precision
    result = Geocoder.search("Madison Square Garden, New York, NY").first
    assert_equal "ROOFTOP",
      result.precision
  end

  def test_all_methods
    query = "Madison Square Garden, New York, NY"
    result = Geocoder.search(query).first

    getters = Geocoder::Result::Google.instance_methods(false)
    getters = getters.reject{|m| m.to_s.start_with? 'address_components' }

    getters.each do |getter|
      geocoder_val = result.send(getter)

      js_method = "get#{getter.to_s.camelize}"
      node_json = `node test/geocoder_test_helper.js test/fixtures/google_madison_square_garden #{js_method}`.strip
      # normal JSON.parse() was complaining about the strings
      node_val = Oj.load(node_json)

      assert_equal geocoder_val, node_val, "failed ##{js_method}()"
    end
  end

end
