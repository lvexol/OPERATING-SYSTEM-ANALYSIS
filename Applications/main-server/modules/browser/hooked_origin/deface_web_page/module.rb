#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Deface_web_page < Server::Core::Command
  def self.options
    @configuration = Server::Core::Configuration.instance
    proto = @configuration.server_proto
    server_host = @configuration.server_host
    server_port = @configuration.server_port
    base_host = "#{proto}://#{server_host}:#{server_port}"

    favicon_uri = "#{base_host}/ui/media/images/favicon.ico"
    [
      { 'name' => 'deface_title', 'description' => 'Page Title', 'ui_label' => 'New Title', 'value' => 'Server - The Browser Exploitation Framework Project',
        'width' => '200px' },
      { 'name' => 'deface_favicon', 'description' => 'Shortcut Icon', 'ui_label' => 'New Favicon', 'value' => favicon_uri, 'width' => '200px' },
      { 'name' => 'deface_content', 'description' => 'Your defacement content', 'ui_label' => 'Deface Content', 'type' => 'textarea', 'value' => 'Server!', 'width' => '400px',
        'height' => '100px' }
    ]
  end

  def post_execute
    content = {}
    content['Result'] = @datastore['result']
    save content
  end
end
