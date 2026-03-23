#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Detect_realplayer < Server::Core::Command
  def post_execute
    content = {}
    content['realplayer'] = @datastore['realplayer']
    save content
  end
end
