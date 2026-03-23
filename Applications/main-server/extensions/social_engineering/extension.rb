#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Extension
    module RegisterSEngHandler
      def self.mount_handler(server)
        server.mount('/api/seng', Server::Extension::SocialEngineering::SEngRest.new)

        ps_url = Server::Core::Configuration.instance.get('server.extension.social_engineering.powershell.powershell_handler_url')
        server.mount(ps_url.to_s, Server::Extension::SocialEngineering::Bind_powershell.new)
      end
    end

    module SocialEngineering
      extend Server::API::Extension

      @short_name = 'social_engineering'
      @full_name = 'Social Engineering'
      @description = 'Web page cloner and other social engineering tools.'

      Server::API::Registrar.instance.register(Server::Extension::RegisterSEngHandler, Server::API::HttpServer, 'mount_handler')
    end
  end
end

# Handlers
require 'extensions/social_engineering/web_cloner/web_cloner'
require 'extensions/social_engineering/web_cloner/interceptor'
require 'extensions/social_engineering/powershell/bind_powershell'

# Models
require 'extensions/social_engineering/models/web_cloner'
require 'extensions/social_engineering/models/interceptor'

# RESTful api endpoints
require 'extensions/social_engineering/rest/socialengineering'
