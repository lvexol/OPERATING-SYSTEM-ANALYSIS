#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Detect_default_browser < Server::Core::Command
  def post_execute
    content = {}
    content['browser'] = @datastore['browser'] unless @datastore['browser'].nil?
    save content
  end
end
