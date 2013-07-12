# encoding: utf-8
require 'test_helper'
require 'active_support/inflector'
require 'oj'

describe Geocoder do
  query = "Madison Square Garden, New York, NY"
  result = Geocoder.search(query).first

  describe query do
    getters = Geocoder::Result::Google.instance_methods(false)
    getters = getters.reject{|m| m.to_s.start_with? 'address_components' }

    getters.each do |getter|
      js_method = "get#{getter.to_s.camelize}"

      it "should have all it's public instance methods available on the GeoFormatter" do
        geocoder_val = result.send(getter)
        node_json = `node test/geocoder_test_helper.js test/fixtures/google_madison_square_garden #{js_method}`.strip
        # normal JSON.parse() was complaining about the strings
        node_val = Oj.load(node_json)

        node_val.must_equal geocoder_val
      end
    end
  end
end
