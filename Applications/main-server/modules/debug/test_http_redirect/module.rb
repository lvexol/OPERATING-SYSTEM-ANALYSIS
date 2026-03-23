#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Test_http_redirect < Server::Core::Command
  def pre_send
    Server::Core::NetworkStack::Handlers::AssetHandler.instance.bind_redirect('https://serverproject.com', '/redirect')
  end

  def post_execute
    content = {}
    content['Result'] = @datastore['result']
    save content
  end
end
