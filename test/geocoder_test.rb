# encoding: utf-8
require 'test_helper'
require 'active_support/inflector'
require 'oj'

class GeocoderTest < Test::Unit::TestCase

  def test_equivalence_of_all_methods
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
