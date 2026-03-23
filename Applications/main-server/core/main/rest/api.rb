#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Core
    module Rest
      module RegisterHooksHandler
        def self.mount_handler(server)
          server.mount('/api/hooks', Server::Core::Rest::HookedBrowsers.new)
        end
      end

      module RegisterBrowserDetailsHandler
        def self.mount_handler(server)
          server.mount('/api/browserdetails', Server::Core::Rest::BrowserDetails.new)
        end
      end

      module RegisterModulesHandler
        def self.mount_handler(server)
          server.mount('/api/modules', Server::Core::Rest::Modules.new)
        end
      end

      module RegisterCategoriesHandler
        def self.mount_handler(server)
          server.mount('/api/categories', Server::Core::Rest::Categories.new)
        end
      end

      module RegisterLogsHandler
        def self.mount_handler(server)
          server.mount('/api/logs', Server::Core::Rest::Logs.new)
        end
      end

      module RegisterAdminHandler
        def self.mount_handler(server)
          server.mount('/api/admin', Server::Core::Rest::Admin.new)
        end
      end

      module RegisterServerHandler
        def self.mount_handler(server)
          server.mount('/api/server', Server::Core::Rest::RestApi.new)
        end
      end

      module RegisterAutorunHandler
        def self.mount_handler(server)
          server.mount('/api/autorun', Server::Core::Rest::AutorunEngine.new)
        end
      end

      Server::API::Registrar.instance.register(Server::Core::Rest::RegisterHooksHandler, Server::API::HttpServer, 'mount_handler')
      Server::API::Registrar.instance.register(Server::Core::Rest::RegisterBrowserDetailsHandler, Server::API::HttpServer, 'mount_handler')
      Server::API::Registrar.instance.register(Server::Core::Rest::RegisterModulesHandler, Server::API::HttpServer, 'mount_handler')
      Server::API::Registrar.instance.register(Server::Core::Rest::RegisterCategoriesHandler, Server::API::HttpServer, 'mount_handler')
      Server::API::Registrar.instance.register(Server::Core::Rest::RegisterLogsHandler, Server::API::HttpServer, 'mount_handler')
      Server::API::Registrar.instance.register(Server::Core::Rest::RegisterAdminHandler, Server::API::HttpServer, 'mount_handler')
      Server::API::Registrar.instance.register(Server::Core::Rest::RegisterServerHandler, Server::API::HttpServer, 'mount_handler')
      Server::API::Registrar.instance.register(Server::Core::Rest::RegisterAutorunHandler, Server::API::HttpServer, 'mount_handler')

      #
      # Check the source IP is within the permitted subnet
      # This is from extensions/admin_ui/controllers/authentication/authentication.rb
      #
      def self.permitted_source?(ip)
        # test if supplied IP address is valid
        return false unless Server::Filters.is_valid_ip?(ip)

        # get permitted subnets
        permitted_ui_subnet = Server::Core::Configuration.instance.get('server.restrictions.permitted_ui_subnet')
        return false if permitted_ui_subnet.nil?
        return false if permitted_ui_subnet.empty?

        # test if ip within subnets
        permitted_ui_subnet.each do |subnet|
          return true if IPAddr.new(subnet).include?(ip)
        end

        false
      end

      #
      # Rate limit through timeout
      # This is from extensions/admin_ui/controllers/authentication/
      #
      # Brute Force Mitigation
      # Only one login request per config_delay_id seconds
      #
      # @param config_delay_id <string> configuration name for the timeout
      # @param last_time_attempt <Time> last time this was attempted
      # @param time_record_set_fn <lambda> callback, setting time on failure
      #
      # @return <boolean>
      def self.timeout?(config_delay_id, last_time_attempt, time_record_set_fn)
        success = true
        time = Time.now
        config = Server::Core::Configuration.instance
        fail_delay = config.get(config_delay_id)

        if time - last_time_attempt < fail_delay.to_f
          time_record_set_fn.call(time)
          success = false
        end

        success
      end
    end
  end
end
