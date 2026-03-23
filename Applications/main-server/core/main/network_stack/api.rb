#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Core
    module NetworkStack
      module RegisterHttpHandler
        # Register the http handler for the network stack
        # @param [Object] server HTTP server instance
        def self.mount_handler(server)
          # @note this mounts the dynamic handler
          server.mount('/dh', Server::Core::NetworkStack::Handlers::DynamicReconstruction.new)
        end
      end

      Server::API::Registrar.instance.register(Server::Core::NetworkStack::RegisterHttpHandler, Server::API::HttpServer, 'mount_handler')
    end
  end
end
