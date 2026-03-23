#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Core
    module Models
      #
      # Store the XssRays scans started and finished, with relative ID
      #
      class Xssraysscan < Server::Core::Model
        has_many :xssrays_details
      end
    end
  end
end
