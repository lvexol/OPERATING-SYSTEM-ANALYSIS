#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#

module Server
  module API
    module Extension
      attr_reader :full_name, :short_name, :description

      @full_name = ''
      @short_name = ''
      @description = ''
    end
  end
end
