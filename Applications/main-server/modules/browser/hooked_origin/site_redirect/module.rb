#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Site_redirect < Server::Core::Command
  def self.options
    [
      { 'ui_label' => 'Redirect URL', 'name' => 'redirect_url', 'description' => 'The URL the target will be redirected to.', 'value' => 'https://serverproject.com/',
        'width' => '200px' }
    ]
  end

  def post_execute
    save({ 'result' => @datastore['result'] })
  end
end
