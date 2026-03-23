#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
module Extension
module WebRTC
  
  module RegisterHttpHandler
    
    Server::API::Registrar.instance.register(Server::Extension::WebRTC::RegisterHttpHandler, Server::API::HttpServer, 'mount_handler')
    
    # We register the http handler for the WebRTC signalling extension.
    # This http handler will handle WebRTC signals from browser to browser

    # We also define an rtc message handler, so that the serverwebrtc object can send messages back into Server
    def self.mount_handler(server_server)
      server_server.mount('/rtcsignal', Server::Extension::WebRTC::SignalHandler)
      server_server.mount('/rtcmessage', Server::Extension::WebRTC::MessengeHandler)
      server_server.mount('/api/webrtc', Server::Extension::WebRTC::WebRTCRest.new)
    end
    
  end

  module RegisterPreHookCallback

    Server::API::Registrar.instance.register(Server::Extension::WebRTC::RegisterPreHookCallback, Server::API::HttpServer::Hook, 'pre_hook_send')

    # We register this pre hook action to ensure that signals going to a browser are included back in the hook.js polling
    # This is also used so that Server can send RTCManagement messages to the hooked browser too
    def self.pre_hook_send(hooked_browser, body, params, request, response)
        dhook = Server::Extension::WebRTC::API::Hook.new
        dhook.requester_run(hooked_browser, body)
    end

  end
  
end
end
end
