#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Test_get_variable < Server::Core::Command
  def self.options
    [{ 'name' => 'payload_name', 'ui_label' => 'Payload Name', 'type' => 'text', 'value' => 'message', 'width' => '400px' }]
  end
end
