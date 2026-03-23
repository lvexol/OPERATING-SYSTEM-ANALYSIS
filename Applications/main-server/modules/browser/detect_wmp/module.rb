#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Detect_wmp < Server::Core::Command
  def post_execute
    content = {}
    content['wmp'] = @datastore['wmp']
    save content
    Server::Core::Models::BrowserDetails.set(@datastore['serverhook'], 'browser.capabilities.wmp', Regexp.last_match(1)) if @datastore['results'] =~ /^wmp=(Yes|No)/
  end
end
