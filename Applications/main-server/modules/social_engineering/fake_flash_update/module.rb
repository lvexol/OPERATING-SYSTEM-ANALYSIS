#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Fake_flash_update < Server::Core::Command
  def pre_send
    Server::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/fake_flash_update/img/eng.png', '/adobe/flash_update', 'png')
  end

  def self.options
    @configuration = Server::Core::Configuration.instance
    proto = @configuration.server_proto
    server_host = @configuration.server_host
    server_port = @configuration.server_port
    base_host = "#{proto}://#{server_host}:#{server_port}"

    image = "#{base_host}/adobe/flash_update.png"

    [
      { 'name' => 'image', 'description' => 'Location of image for the update prompt', 'ui_label' => 'Image', 'value' => image },
      { 'name' => 'payload_uri', 'description' => 'Payload URI', 'ui_label' => 'Payload URI', 'value' => '' }
    ]
  end

  def post_execute
    content = {}
    content['result'] = @datastore['result']
    save content

    Server::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/adobe/flash_update.png')
  end
end
