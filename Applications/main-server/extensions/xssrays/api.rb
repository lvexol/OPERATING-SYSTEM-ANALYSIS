#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Extension
    module Xssrays
      module RegisterHttpHandler
        Server::API::Registrar.instance.register(Server::Extension::Xssrays::RegisterHttpHandler, Server::API::HttpServer, 'mount_handler')

        #
        # Mounts the handlers and REST interface for processing XSS rays
        #
        # @param server_server [Server::Core::HttpServer] HTTP server instance
        #
        def self.mount_handler(server_server)
          # We register the http handler for the requester.
          # This http handler will retrieve the http responses for all requests
          server_server.mount('/xssrays', Server::Extension::Xssrays::Handler.new)
          # REST API endpoint
          server_server.mount('/api/xssrays', Server::Extension::Xssrays::XssraysRest.new)
        end
      end

      module RegisterPreHookCallback
        Server::API::Registrar.instance.register(Server::Extension::Xssrays::RegisterPreHookCallback, Server::API::HttpServer::Hook, 'pre_hook_send')

        # checks at every polling if there are new scans to be started
        def self.pre_hook_send(hooked_browser, body, _params, _request, _response)
          return if hooked_browser.nil?

          xssrays = Server::Extension::Xssrays::API::Scan.new
          xssrays.start_scan(hooked_browser, body)
        end
      end
    end
  end
end
