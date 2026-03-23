#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Detect_simple_adblock < Server::Core::Command
  def post_execute
    content = {}
    content['simple_adblock'] = @datastore['simple_adblock'] unless @datastore['simple_adblock'].nil?
    save content
  end
end
