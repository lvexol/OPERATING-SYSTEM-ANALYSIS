#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Extension
    module Qrcode
      extend Server::API::Extension

      @short_name = 'qrcode'
      @full_name = 'QR Code Generator'
      @description = 'This extension generates QR Codes for specified URLs which can be used to hook browsers into Server.'
    end
  end
end

require 'extensions/qrcode/qrcode'
