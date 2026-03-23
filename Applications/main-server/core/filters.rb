#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Filters
  end
end

# @note Include the filters
require 'core/filters/base'
require 'core/filters/browser'
require 'core/filters/command'
require 'core/filters/page'
require 'core/filters/http'
