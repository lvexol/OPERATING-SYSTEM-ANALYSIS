#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Link_rewrite < Server::Core::Command
  def self.options
    [
      { 'ui_label' => 'URL', 'name' => 'url', 'description' => 'Target URL', 'value' => 'https://serverproject.com/', 'width' => '200px' }
    ]
  end

  def post_execute
    save({ 'result' => @datastore['result'] })
  end
end
