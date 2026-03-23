#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Extension
    module ETag
      extend Server::API::Extension

      @short_name  = 'ETag'
      @full_name   = 'Server-to-Client ETag-based Covert Timing Channel'
      @description = 'This extension provides a custom Server HTTP server ' \
                     'that implements unidirectional covert timing channel from ' \
                     'Server communication server to zombie browser over Etag header.'
    end
  end
end

require 'extensions/etag/api'
require 'extensions/etag/etag'
