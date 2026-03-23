#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Get_all_cookies < Server::Core::Command
  def self.options
    [
      { 'name' => 'url', 'ui_label' => 'Domain (e.g. http://facebook.com)', 'value' => 'default_all' }
    ]
  end

  def post_execute
    content = {}
    content['Return'] = @datastore['return']
    save content
  end
end
