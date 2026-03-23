#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Invisible_iframe < Server::Core::Command
  def self.options
    [
      { 'name' => 'target', 'ui_label' => 'URL', 'value' => 'https://serverproject.com/' }
    ]
  end

  def post_execute
    save({ 'result' => @datastore['result'] })
  end
end
