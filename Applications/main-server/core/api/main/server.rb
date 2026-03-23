#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module API
    module HttpServer
      # @note Defined API Paths
      API_PATHS = {
        'mount_handler' => :mount_handler,
        'pre_http_start' => :pre_http_start
      }.freeze

      # Fires just before the HTTP Server is started
      # @param [Object] http_hook_server HTTP Server object
      def pre_http_start(http_hook_server); end

      # Fires just after handlers have been mounted
      # @param [Object] server HTTP Server object
      def mount_handler(server); end

      # Mounts a handler
      # @param [String] url URL to be mounted
      # @param [Class] http_handler_class the handler Class
      # @param [Array] args an array of arguments
      # @note This is a direct API call and does not have to be registered to be used
      def self.mount(url, http_handler_class, args = nil)
        Server::Core::HttpServer.instance.mount(url, http_handler_class, *args)
      end

      # Unmounts a handler
      # @param [String] url URL to be unmounted
      # @note This is a direct API call and does not have to be registered to be used
      def self.unmount(url)
        Server::Core::HttpServer.instance.unmount(url)
      end
    end
  end
end
