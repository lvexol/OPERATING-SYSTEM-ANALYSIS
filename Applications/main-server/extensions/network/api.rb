#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Extension
    module Network
      module RegisterHttpHandler
        Server::API::Registrar.instance.register(Server::Extension::Network::RegisterHttpHandler, Server::API::HttpServer, 'mount_handler')

        # Mounts the handler for processing network host info.
        #
        # @param server_server [Server::Core::HttpServer] HTTP server instance
        def self.mount_handler(server_server)
          server_server.mount('/api/network', Server::Extension::Network::NetworkRest.new)
        end
      end
    end
  end
end
