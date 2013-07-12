require 'rubygems'
require 'minitest/spec'
require 'minitest/autorun'

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
