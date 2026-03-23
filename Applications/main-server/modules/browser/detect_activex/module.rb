#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Detect_activex < Server::Core::Command
  def post_execute
    content = {}
    content['activex'] = @datastore['activex']
    save content

    activex = @datastore['results'].scan(/^activex=(Yes|No)/).flatten.first
    return unless activex

    Server::Core::Models::BrowserDetails.set(@datastore['serverhook'], 'browser.capabilities.activex', activex)
  end
end
