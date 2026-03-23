#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
# phonegap
#

class Phonegap_detect < Server::Core::Command
  def post_execute
    content = {}
    content['phonegap'] = @datastore['phonegap']
    save content
  end
end
