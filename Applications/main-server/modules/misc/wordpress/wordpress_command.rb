#
# Copyright (c) Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
# Author Erwan LR (@erwan_lr | WPScanTeam) - https://wpscan.org/
#

require 'securerandom'

class WordPressCommand < Server::Core::Command
  def pre_send
    Server::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/misc/wordpress/wp.js', '/wp', 'js')
  end

  # If we could retrive the hooked URL, we could try to determine the wp_path to be set below
  def self.options
    [
      { 'name' => 'wp_path', 'ui_label' => 'WordPress Path', 'value' => '/' }
    ]
  end

  # This one is triggered each time a server.net.send is called
  def post_execute
    Server::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('wp.js')

    return unless @datastore['result']

    save({ 'result' => @datastore['result'] })
  end
end
