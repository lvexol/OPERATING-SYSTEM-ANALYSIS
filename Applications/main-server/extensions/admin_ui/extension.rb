#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Extension
    module AdminUI
      extend Server::API::Extension

      @full_name = 'Administration Web UI'
      @short_name = 'admin_ui'
      @description = 'Command and control web interface'
    end
  end
end

# Constants
require 'extensions/admin_ui/constants/icons'

# Classes
require 'extensions/admin_ui/classes/httpcontroller'
require 'extensions/admin_ui/classes/session'

# Handlers
require 'extensions/admin_ui/handlers/ui'

# API Hooking
require 'extensions/admin_ui/api/handler'
