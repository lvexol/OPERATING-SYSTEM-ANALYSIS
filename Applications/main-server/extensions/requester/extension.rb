#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Extension
    module Requester
    end
  end
end

require 'extensions/requester/models/http'
require 'extensions/requester/api/hook'
require 'extensions/requester/handler'
require 'extensions/requester/api'
require 'extensions/requester/rest/requester'
