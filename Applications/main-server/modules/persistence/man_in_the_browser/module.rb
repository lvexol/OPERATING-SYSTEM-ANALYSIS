#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#

class Man_in_the_browser < Server::Core::Command
  def post_execute
    save({ 'result' => @datastore['result'] })
  end
end
