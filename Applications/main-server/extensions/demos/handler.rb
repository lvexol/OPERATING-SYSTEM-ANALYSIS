#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Extension
    module Demos
      class Handler < Server::Core::Router::Router
        set :public_folder, File.expand_path(File.dirname(__FILE__)) + '/html/'
      end
    end
  end
end
