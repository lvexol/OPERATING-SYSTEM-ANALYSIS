#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Get_page_html_iframe < Server::Core::Command
  def post_execute
    content = {}
    content['head'] = @datastore['head']
    content['body'] = @datastore['body']
    content['iframe_'] = @datastore['iframe_']
    save content
  end
end
