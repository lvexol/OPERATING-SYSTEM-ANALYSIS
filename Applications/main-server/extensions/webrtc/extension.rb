#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
module Extension
module WebRTC

	extend Server::API::Extension

    @short_name = 'webrtc'
    @full_name = 'WebRTC'
    @description = 'WebRTC extension to all browsers to connect to each other (P2P) with WebRTC'
  
end
end
end

require 'extensions/webrtc/models/rtcsignal'
require 'extensions/webrtc/models/rtcmanage'
require 'extensions/webrtc/models/rtcstatus'
require 'extensions/webrtc/models/rtcmodulestatus'
require 'extensions/webrtc/api/hook'
require 'extensions/webrtc/handlers'
require 'extensions/webrtc/api'
require 'extensions/webrtc/rest/webrtc'
