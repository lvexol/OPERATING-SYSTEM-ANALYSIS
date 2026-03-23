#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Extension
    module Customhook
      module RegisterHttpHandlers
        Server::API::Registrar.instance.register(Server::Extension::Customhook::RegisterHttpHandlers, Server::API::HttpServer, 'mount_handler')
        Server::API::Registrar.instance.register(Server::Extension::Customhook::RegisterHttpHandlers, Server::API::HttpServer, 'pre_http_start')

        def self.mount_handler(server_server)
          configuration = Server::Core::Configuration.instance
          configuration.get('server.extension.customhook.hooks').each do |h|
            server_server.mount(configuration.get("server.extension.customhook.hooks.#{h.first}.path"), Server::Extension::Customhook::Handler.new)
          end
        end

        def self.pre_http_start(_server_server)
          configuration = Server::Core::Configuration.instance
          configuration.get('server.extension.customhook.hooks').each do |h|
            print_success 'Successfully mounted a custom hook point'
            print_more "Mount Point: #{configuration.get("server.extension.customhook.hooks.#{h.first}.path")}\nLoading iFrame: #{configuration.get("server.extension.customhook.hooks.#{h.first}.target")}\n"
          end
        end
      end
    end
  end
end
