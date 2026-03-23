#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#

class Webcam_permission_check < Server::Core::Command
  def pre_send
    Server::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/browser/webcam_permission_check/cameraCheck.swf', '/cameraCheck', 'swf')
    Server::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/browser/webcam_permission_check/swfobject.js', '/swfobject', 'js')
  end

  def post_execute
    Server::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/cameraCheck.swf')
    Server::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/swfobject.js')
  end
end
