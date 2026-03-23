#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Extension
    module Requester
      module RegisterHttpHandler
        Server::API::Registrar.instance.register(Server::Extension::Requester::RegisterHttpHandler, Server::API::HttpServer, 'mount_handler')

        def self.mount_handler(server_server)
          server_server.mount('/requester', Server::Extension::Requester::Handler)
          server_server.mount('/api/requester', Server::Extension::Requester::RequesterRest.new)
        end
      end

      module RegisterPreHookCallback
        Server::API::Registrar.instance.register(Server::Extension::Requester::RegisterPreHookCallback, Server::API::HttpServer::Hook, 'pre_hook_send')

        def self.pre_hook_send(hooked_browser, body, _params, _request, _response)
          dhook = Server::Extension::Requester::API::Hook.new
          dhook.requester_run(hooked_browser, body)
        end
      end
    end
  end
end
