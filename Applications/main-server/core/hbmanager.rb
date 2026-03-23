#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module HBManager
    # Get hooked browser by session id
    # @param [String] sid hooked browser session id string
    # @return [Server::Core::Models::HookedBrowser] returns the associated Hooked Browser
    def self.get_by_session(sid)
      Server::Core::Models::HookedBrowser.where(session: sid).first
    end

    # Get hooked browser by id
    # @param [Integer] id hooked browser database id
    # @return [Server::Core::Models::HookedBrowser] returns the associated Hooked Browser
    def self.get_by_id(id)
      Server::Core::Models::HookedBrowser.find(id)
    end
  end
end
