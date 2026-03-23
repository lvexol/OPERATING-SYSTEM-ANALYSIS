#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#

require 'extensions/notifications/channels/email'
require 'extensions/notifications/channels/pushover'
require 'extensions/notifications/channels/slack_workspace'
require 'extensions/notifications/channels/ntfy'


module Server
  module Extension
    module Notifications
      #
      # Notifications class
      #
      class Notifications
        def initialize(from, event, time_now, hb)
          @config = Server::Core::Configuration.instance
          return unless @config.get('server.extension.notifications.enable')

          @from = from
          @event = event
          @time_now = time_now
          @hb = hb

          message = "#{from} #{event} #{time_now} #{hb}"

          if @config.get('server.extension.notifications.email.enable') == true
            to_address = @config.get('server.extension.notifications.email.to_address')
            Server::Extension::Notifications::Channels::Email.new(to_address, message)
          end

          Server::Extension::Notifications::Channels::Pushover.new(message) if @config.get('server.extension.notifications.pushover.enable') == true

          Server::Extension::Notifications::Channels::SlackWorkspace.new(message) if @config.get('server.extension.notifications.slack.enable') == true

          Server::Extension::Notifications::Channels::Ntfy.new(message) if @config.get('server.extension.notifications.ntfy.enable') == true

        end
      end
    end
  end
end
