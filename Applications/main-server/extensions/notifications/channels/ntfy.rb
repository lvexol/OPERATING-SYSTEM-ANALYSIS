require 'net/http'
require 'uri'

module Server
  module Extension
    module Notifications
      module Channels
        class Ntfy

          # Constructor
          def initialize(message)
            @config = Server::Core::Configuration.instance

            # Endpoint URL
            uri = URI.parse(@config.get('server.extension.notifications.ntfy.endpoint_url'))

            # Create client
            http = Net::HTTP.new(uri.host, uri.port)

            # Create Request
            req = Net::HTTP::Post.new(uri.path)

            # Add authentication if configured
            if @config.get('server.extension.notifications.ntfy.username') || @config.get('server.extension.notifications.ntfy.password')
              req.basic_auth @config.get('server.extension.notifications.ntfy.username'), @config.get('server.extension.notifications.ntfy.password')
            end

            # Set headers and body
            req.content_type = 'text/plain'
            req['Title'] = 'Server Notification'
            req.body = message

            # Use SSL if the URI scheme is 'https'
            http.use_ssl = (uri.scheme == 'https')

            # Send request
            http.request(req)
          end

        end
      end
    end
  end
end
