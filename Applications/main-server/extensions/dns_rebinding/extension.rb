#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Extension
    module DNSRebinding
      extend Server::API::Extension

      @short_name  = 'DNS Rebinding'
      @full_name   = 'DNS Rebinding'
      @description = 'DNS Rebinding extension'
    end
  end
end

require 'extensions/dns_rebinding/api'
require 'extensions/dns_rebinding/dns_rebinding'
