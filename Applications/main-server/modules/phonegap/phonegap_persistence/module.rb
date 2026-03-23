#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
# phonegap persistenece
#

class Phonegap_persistence < Server::Core::Command
  def self.options
    @configuration = Server::Core::Configuration.instance
    proto = @configuration.server_proto
    server_host = @configuration.server_host
    server_port = @configuration.server_port
    hook_file = @configuration.hook_file_path

    [{
      'name' => 'hook_url',
      'description' => 'The URL of your Server hook',
      'ui_label' => 'Hook URL',
      'value' => "#{proto}://#{server_host}:#{server_port}#{hook_file}",
      'width' => '300px'
    }]
  end

  def post_execute
    content = {}
    content['result'] = @datastore['result']
    save content
  end
end
