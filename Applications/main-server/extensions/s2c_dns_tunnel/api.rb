#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Extension
    module ServerClientDnsTunnel
      module API
        module ServerClientDnsTunnelHandler
          Server::API::Registrar.instance.register(Server::Extension::ServerClientDnsTunnel::API::ServerClientDnsTunnelHandler,
                                                 Server::API::HttpServer, 'pre_http_start')
          Server::API::Registrar.instance.register(Server::Extension::ServerClientDnsTunnel::API::ServerClientDnsTunnelHandler,
                                                 Server::API::HttpServer, 'mount_handler')

          # Starts the S2C DNS Tunnel server at Server startup.
          # @param http_hook_server [Server::Core::HttpServer] HTTP server instance
          def self.pre_http_start(_http_hook_server)
            configuration = Server::Core::Configuration.instance
            zone = configuration.get('server.extension.s2c_dns_tunnel.zone')
            raise ArgumentError, 'zone name is undefined' unless zone.to_s != ''

            # if listen parameter is not defined in the config.yaml then interface with the highest Server's IP-address will be choosen
            listen = configuration.get('server.extension.s2c_dns_tunnel.listen')
            Socket.ip_address_list.map { |x| listen = x.ip_address if x.ipv4? } if listen.to_s.empty?

            port = 53
            protocol = :udp
            interfaces = [[protocol, listen, port]]
            dns = Server::Extension::ServerClientDnsTunnel::Server.instance
            dns.run(listen: interfaces, zone: zone)

            print_info "Server-to-Client DNS Tunnel Server: #{listen}:#{port} (#{protocol})"
            info = ''
            info += "Zone: #{zone}\n"
            print_more info
          end

          # Mounts the handler for processing HTTP image requests.
          # @param server_server [Server::Core::HttpServer] HTTP server instance
          def self.mount_handler(server_server)
            configuration = Server::Core::Configuration.instance
            zone = configuration.get('server.extension.s2c_dns_tunnel.zone')
            server_server.mount('/tiles', Server::Extension::ServerClientDnsTunnel::Httpd.new(zone))
          end
        end
      end
    end
  end
end
