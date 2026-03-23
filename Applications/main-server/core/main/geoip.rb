#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#

module Server
  module Core
    class GeoIp
      include Singleton

      def initialize
        @config = Server::Core::Configuration.instance
        @enabled = @config.get('server.geoip.enable') ? true : false

        return unless @enabled

        geoip_file = @config.get('server.geoip.database')

        unless File.exist? geoip_file
          Server::Core::Logger.instance.register('System', "[GeoIP] Could not find MaxMind GeoIP database: '#{geoip_file}'")
          @enabled = false
          return
        end

        require 'maxmind/db'
        @geoip_reader = MaxMind::DB.new(geoip_file, mode: MaxMind::DB::MODE_MEMORY)
        @geoip_reader.freeze
      rescue StandardError => e
        print_error "[GeoIP] Failed to load GeoIP database: #{e.message}"
        @enabled = false
      end

      #
      # Check if GeoIP functionality is enabled and functional
      #
      # @return [Boolean] GeoIP functionality enabled?
      #
      def enabled?
        @enabled
      end

      #
      # Search the MaxMind GeoLite2 database for the specified IP address
      #
      # @param [String] The IP address to lookup
      #
      # @return [Hash] IP address lookup results
      #
      def lookup(ip)
        raise TypeError, '"ip" needs to be a string' unless ip.is_a?(String)

        return unless @enabled

        @geoip_reader.get(ip)
      end
    end
  end
end
