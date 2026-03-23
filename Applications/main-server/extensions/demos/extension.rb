#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Extension
    module Demos
      extend Server::API::Extension

      @short_name = 'demos'
      @full_name = 'demonstrations'
      @description = 'Demonstration pages for Server'
    end
  end
end

require 'extensions/demos/api'
require 'extensions/demos/handler'
