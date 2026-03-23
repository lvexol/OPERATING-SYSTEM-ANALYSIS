#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Core
    module Models
      #
      # Objects stores known 'legacy' browser User Agents.
      #
      # This table is used to determine if a hooked browser is a 'legacy' 
      # browser.
      #
      # TODO: make it an actual table
      #
      module LegacyBrowserUserAgents
        def self.user_agents
          [
          ]
        end
      end
    end
  end
end
