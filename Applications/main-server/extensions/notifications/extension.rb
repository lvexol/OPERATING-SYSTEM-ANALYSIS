#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Extension
    module Notifications
      extend Server::API::Extension

      @short_name = 'notifications'
      @full_name = 'Notifications'
      @description = 'Generates external notifications for events in Server'
    end
  end
end

require 'extensions/notifications/notifications'
