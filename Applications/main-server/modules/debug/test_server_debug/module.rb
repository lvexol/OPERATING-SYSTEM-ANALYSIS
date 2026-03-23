#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Test_server_debug < Server::Core::Command
  def self.options
    [
      { 'name' => 'msg', 'description' => 'Debug Message', 'ui_label' => 'Debug Message', 'value' => 'Test string for server.debug() function', 'type' => 'textarea',
        'width' => '400px', 'height' => '50px' }
    ]
  end

  def post_execute
    content = {}
    content['Result'] = @datastore['result']
    save content
  end
end
