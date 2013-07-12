require 'rubygems'
require 'test/unit'

$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'geocoder'
require "geocoder/lookups/base"

##
# Mock HTTP request to geocoding service.
#
module Geocoder
  module Lookup
    class Base
      private
      def fixture_exists?(filename)
        File.exist?(File.join("test", "fixtures", filename))
      end

      def read_fixture(file)
        filepath = File.join("test", "fixtures", file)
        s = File.read(filepath).strip.gsub(/\n\s*/, "")
        s.instance_eval do
          def body; self; end
          def code; "200"; end
        end
        s
      end

      ##
      # Fixture to use if none match the given query.
      #
      def default_fixture_filename
        "#{fixture_prefix}_madison_square_garden"
      end

      def fixture_prefix
        handle
      end

      def fixture_for_query(query)
        label = query.reverse_geocode? ? "reverse" : query.text.gsub(/[ \.]/, "_")
        filename = "#{fixture_prefix}_#{label}"
        fixture_exists?(filename) ? filename : default_fixture_filename
      end

      def make_api_request(query)
        raise TimeoutError if query.text == "timeout"
        raise SocketError if query.text == "socket_error"
        read_fixture fixture_for_query(query)
      end
    end

  end
end


class Test::Unit::TestCase

  def setup
    Geocoder.configure(:maxmind => {:service => :city_isp_org})
  end

  def teardown
    Geocoder.send(:remove_const, :Configuration)
    load "geocoder/configuration.rb"
  end

  def venue_params(abbrev)
    {
      :msg => ["Madison Square Garden", "4 Penn Plaza, New York, NY"]
    }[abbrev]
  end

  def landmark_params(abbrev)
    {
      :msg => ["Madison Square Garden", 40.750354, -73.993371]
    }[abbrev]
  end

  def is_nan_coordinates?(coordinates)
    return false unless coordinates.respond_to? :size # Should be an array
    return false unless coordinates.size == 2 # Should have dimension 2
    coordinates[0].nan? && coordinates[1].nan? # Both coordinates should be NaN
  end

  def set_api_key!(lookup_name)
    lookup = Geocoder::Lookup.get(lookup_name)
    if lookup.required_api_key_parts.size == 1
      key = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
    elsif lookup.required_api_key_parts.size > 1
      key = lookup.required_api_key_parts
    else
      key = nil
    end
    Geocoder.configure(:api_key => key)
  end
end
