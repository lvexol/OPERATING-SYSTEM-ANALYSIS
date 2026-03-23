#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#

module Server
module Core
module Models
  #
  # Table stores the webrtc status information
  # This includes things like connection status, and executed modules etc
  #
  

  class Rtcmodulestatus < Server::Core::Model
      
      belongs_to :hooked_browser
      belongs_to :command_module
  

  end
  
end
end
end
