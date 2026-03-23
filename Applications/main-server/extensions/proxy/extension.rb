#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Extension
    module Proxy
      extend Server::API::Extension

      @short_name = 'proxy'
      @full_name = 'proxy'
      @description = 'The tunneling proxy allows HTTP requests to the hooked origin to be tunneled through the victim browser'
    end
  end
end

require 'extensions/requester/models/http'
# require 'extensions/proxy/models/http'
require 'extensions/proxy/proxy'
require 'extensions/proxy/api'
require 'extensions/proxy/rest/proxy'
