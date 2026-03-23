#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Core
    module Models
      class Interceptor < Server::Core::Model
        belongs_to :webcloner
      end
    end
  end
end
