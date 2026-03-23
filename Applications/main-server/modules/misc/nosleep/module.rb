#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class No_sleep < Server::Core::Command
  def pre_send
    Server::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/misc/nosleep/NoSleep.min.js', '/NoSleep', 'js')
  end

  def self.options
    []
  end

  def post_execute
    content = {}
    content['result'] = @datastore['result']
    Server::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('NoSleep.js')
    save content
  end
end
