#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Extension
    module Events
      # Mounts the handler for processing browser events.
      #
      # @param server_server [Server::Core::HttpServer] HTTP server instance
      module RegisterHttpHandler
        Server::API::Registrar.instance.register(Server::Extension::Events::RegisterHttpHandler, Server::API::HttpServer, 'mount_handler')

        def self.mount_handler(server_server)
          server_server.mount('/event', Server::Extension::Events::Handler)
        end
      end
    end
  end
end
