#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Extension
    module Demos
      module RegisterHttpHandlers
        Server::API::Registrar.instance.register(Server::Extension::Demos::RegisterHttpHandlers, Server::API::HttpServer, 'mount_handler')

        #
        # Mounts the handlers for the demos pages
        #
        # @param server_server [Server::Core::HttpServer] HTTP server instance
        #
        def self.mount_handler(server_server)
          server_server.mount('/demos', Server::Extension::Demos::Handler.new)
        end
      end
    end
  end
end
