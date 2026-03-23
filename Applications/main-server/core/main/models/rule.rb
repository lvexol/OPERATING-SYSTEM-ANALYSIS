#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#

module Server
  module Core
    module Models
      # @note Table stores the rules for the Distributed Engine.
      class Rule < Server::Core::Model
        has_many :executions
      end
    end
  end
end
