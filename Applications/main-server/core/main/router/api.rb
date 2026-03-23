#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Core
    module Router
      module RegisterRouterHandler
        def self.mount_handler(server)
          server.mount('/', Server::Core::Router::Router.new)
        end
      end

      Server::API::Registrar.instance.register(Server::Core::Router::RegisterRouterHandler, Server::API::HttpServer, 'mount_handler')
    end
  end
end
