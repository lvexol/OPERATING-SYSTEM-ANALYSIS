#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Core
    module Models
      class Result < Server::Core::Model
        has_one :command
        has_one :hooked_browser
      end
    end
  end
end
