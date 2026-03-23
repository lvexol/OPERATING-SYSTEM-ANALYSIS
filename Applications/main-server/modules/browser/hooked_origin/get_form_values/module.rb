#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Get_form_values < Server::Core::Command
  def post_execute
    content = {}
    content['result'] = @datastore['result']
    save content
  end
end
