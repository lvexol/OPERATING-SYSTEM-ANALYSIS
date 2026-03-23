#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Core
    module Models
      #
      # Store the rays details, basically verified XSS vulnerabilities
      #
      class Xssraysdetail < Server::Core::Model
        belongs_to :hooked_browser
        belongs_to :xssraysscan
      end
    end
  end
end
