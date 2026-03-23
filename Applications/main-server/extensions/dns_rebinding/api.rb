#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Extension
    module DNSRebinding
      module API
        module ServHandler
          Server::API::Registrar.instance.register(
            Server::Extension::DNSRebinding::API::ServHandler,
            Server::API::HttpServer,
            'pre_http_start'
          )

          def self.pre_http_start(_http_hook_server)
            config = Server::Core::Configuration.instance.get('server.extension.dns_rebinding')
            address_http = config['address_http_internal']
            address_proxy = config['address_proxy_internal']
            port_http = config['port_http']
            port_proxy = config['port_proxy']
            Thread.new { Server::Extension::DNSRebinding::Server.run_server(address_http, port_http) }
            Thread.new { Server::Extension::DNSRebinding::Proxy.run_server(address_proxy, port_proxy) }
          end
        end
      end
    end
  end
end
