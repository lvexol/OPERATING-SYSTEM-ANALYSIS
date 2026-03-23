#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Test_return_ascii_chars < Server::Core::Command
  def post_execute
    content = {}
    content['Result String'] = @datastore['result_string']
    save content
  end
end
