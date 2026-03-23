#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module API
    module Extensions
      # @note Defined API Paths
      API_PATHS = {
        'post_load' => :post_load
      }.freeze

      # API hook fired after all extensions have been loaded
      def post_load; end
    end
  end
end
