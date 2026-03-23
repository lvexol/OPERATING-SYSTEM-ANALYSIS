#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Extension
    module Proxy
      module API
        module RegisterHttpHandler
          Server::API::Registrar.instance.register(Server::Extension::Proxy::API::RegisterHttpHandler, Server::API::HttpServer, 'pre_http_start')
          Server::API::Registrar.instance.register(Server::Extension::Proxy::API::RegisterHttpHandler, Server::API::HttpServer, 'mount_handler')

          def self.pre_http_start(http_hook_server)
            config = Server::Core::Configuration.instance
            Thread.new do
              http_hook_server.semaphore.synchronize do
                Server::Extension::Proxy::Proxy.new
              end
            end
          end

          def self.mount_handler(server_server)
            server_server.mount('/api/proxy', Server::Extension::Proxy::ProxyRest.new)
          end
        end
      end
    end
  end
end
