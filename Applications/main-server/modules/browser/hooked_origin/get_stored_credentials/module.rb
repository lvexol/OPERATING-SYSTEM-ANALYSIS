#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Get_stored_credentials < Server::Core::Command
  def self.options
    @configuration = Server::Core::Configuration.instance
    proto = @configuration.server_proto
    server_host = @configuration.server_host
    server_port = @configuration.server_port
    base_host = "#{proto}://#{server_host}:#{server_port}"

    uri = "#{base_host}/demos/butcher/index.html"
    [
      { 'name' => 'login_url', 'description' => 'Login URL', 'ui_label' => 'Login URL', 'value' => uri, 'width' => '400px' }
    ]
  end

  def post_execute
    content = {}
    content['form_data'] = @datastore['form_data']
    save content
  end
end
