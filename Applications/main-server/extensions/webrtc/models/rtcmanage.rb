#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
module Core
module Models
  #
  # Table stores the queued up JS commands for managing the client-side webrtc logic.
  #
  class RtcManage < Server::Core::Model
  
    # Starts the RTCPeerConnection process, establishing a WebRTC connection between the caller and the receiver
    def self.initiate(caller, receiver, verbosity = false)
      stunservers = Server::Core::Configuration.instance.get("server.extension.webrtc.stunservers")
      turnservers = Server::Core::Configuration.instance.get("server.extension.webrtc.turnservers")

      # Add the server.webrtc.start() JavaScript call into the RtcManage table - this will be picked up by the browser on next hook.js poll
      # This is for the Receiver
      r = Server::Core::Models::RtcManage.new(:hooked_browser_id => receiver, :message => "server.webrtc.start(0,#{caller},JSON.stringify(#{turnservers}),JSON.stringify(#{stunservers}),#{verbosity});")
      r.save!
      
      # This is the same server.webrtc.start() JS call, but for the Caller
      r = Server::Core::Models::RtcManage.new(:hooked_browser_id => caller, :message => "server.webrtc.start(1,#{receiver},JSON.stringify(#{turnservers}),JSON.stringify(#{stunservers}),#{verbosity});")
      r.save!
    end

    # Advises a browser to send an RTCDataChannel message to its peer
    # Similar to the initiate method, this loads up a JavaScript call to the serverrtcs[peerid].sendPeerMsg() function call
    def self.sendmsg(from, to, message)
      r = Server::Core::Models::RtcManage.new(:hooked_browser_id => from, :message => "serverrtcs[#{to}].sendPeerMsg('#{message}');")
      r.save!
    end

    # Gets the browser to run the server.webrtc.status() JavaScript function
    # This JS function will return it's values to the /rtcmessage handler
    def self.status(id)
      r = Server::Core::Models::RtcManage.new(:hooked_browser_id => id, :message => "server.webrtc.status(#{id});")
      r.save!
    end

  end
  
end
end
end
