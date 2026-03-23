#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Extension
    module Customhook
      extend Server::API::Extension

      @short_name = 'customhook'

      @full_name = 'Custom Hook Point with iFrame Impersonation'

      @description = 'An auto-hook and full-screen iframe - demonstrating extension creation and social engineering attacks'
    end
  end
end

require 'extensions/customhook/api'
require 'extensions/customhook/handler'
