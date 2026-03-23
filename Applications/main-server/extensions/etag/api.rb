#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Extension
    module ETag
      module API
        module ETagHandler
          Server::API::Registrar.instance.register(
            Server::Extension::ETag::API::ETagHandler,
            Server::API::HttpServer,
            'mount_handler'
          )

          def self.mount_handler(server_server)
            server_server.mount('/etag', Server::Extension::ETag::ETagWebServer.new!)
            print_info 'ETag Server: /etag'
          end
        end
      end
    end
  end
end
