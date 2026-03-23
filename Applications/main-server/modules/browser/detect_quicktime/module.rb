#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Detect_quicktime < Server::Core::Command
  def post_execute
    content = {}
    content['quicktime'] = @datastore['quicktime']
    save content
  end
end
