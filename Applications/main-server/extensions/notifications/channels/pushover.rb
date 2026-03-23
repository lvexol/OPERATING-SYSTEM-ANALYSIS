require 'rushover'

module Server
  module Extension
    module Notifications
      module Channels
        class Pushover
          def initialize(message)
            @config = Server::Core::Configuration.instance

            # Configure the Pushover Client
            client = Rushover::Client.new(@config.get('server.extension.notifications.pushover.app_key'))

            res = client.notify(@config.get('server.extension.notifications.pushover.user_key'), message)
            print_error '[Notifications] Pushover notification failed' unless res.ok?
          rescue StandardError => e
            print_error "[Notifications] Pushover notification initialization failed: '#{e.message}'"
          end
        end
      end
    end
  end
end
