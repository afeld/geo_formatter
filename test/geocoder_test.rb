# encoding: utf-8
require 'test_helper'
require 'active_support/inflector'
require 'oj'

describe Geocoder do
  fixture = 'madison_square_garden'
  result = Geocoder.search(fixture).first

  describe fixture do
    getters = Geocoder::Result::Google.instance_methods(false)
    getters = getters.reject{|m| m.to_s.start_with? 'address_components' }

    getters.each do |getter|
      js_method = "get#{getter.to_s.camelize}"

      it "should match :#{getter}" do
        geocoder_val = result.send(getter)
        node_json = `node test/geocoder_test_helper.js test/fixtures/#{fixture}.json #{js_method}`.strip
        # normal JSON.parse() was complaining about the strings
        node_val = Oj.load(node_json)

        node_val.must_equal geocoder_val
      end
    end
  end
end
