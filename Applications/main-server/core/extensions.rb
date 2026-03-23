#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Extensions
    # Returns configuration of all enabled extensions
    # @return [Array] an array of extension configuration hashes that are enabled
    def self.get_enabled
      Server::Core::Configuration.instance.get('server.extension').select { |_k, v| v['enable'] == true }
    rescue StandardError => e
      print_error "Failed to get enabled extensions: #{e.message}"
      print_error e.backtrace
    end

    # Returns configuration of all loaded extensions
    # @return [Array] an array of extension configuration hashes that are loaded
    def self.get_loaded
      Server::Core::Configuration.instance.get('server.extension').select { |_k, v| v['loaded'] == true }
    rescue StandardError => e
      print_error "Failed to get loaded extensions: #{e.message}"
      print_error e.backtrace
    end

    # Load all enabled extensions
    # @note API fire for post_load
    def self.load
      Server::Core::Configuration.instance.load_extensions_config
      get_enabled.each do |k, _v|
        Server::Extension.load k
      end
      # API post extension load
      Server::API::Registrar.instance.fire Server::API::Extensions, 'post_load'
    rescue StandardError => e
      print_error "Failed to load extensions: #{e.message}"
      print_error e.backtrace
    end
  end
end
