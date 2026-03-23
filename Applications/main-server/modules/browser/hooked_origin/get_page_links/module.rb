#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Get_page_links < Server::Core::Command
  def post_execute
    content = {}
    content['links'] = @datastore['links']

    save content
  end
end
