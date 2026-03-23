#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Detect_unsafe_activex < Server::Core::Command
  def post_execute
    content = {}
    content['unsafe_activex'] = @datastore['unsafe_activex']
    save content
  end
end
