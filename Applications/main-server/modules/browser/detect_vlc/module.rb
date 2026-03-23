#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Detect_vlc < Server::Core::Command
  def post_execute
    content = {}
    content['vlc'] = @datastore['vlc']
    save content
    Server::Core::Models::BrowserDetails.set(@datastore['serverhook'], 'browser.capabilities.vlc', Regexp.last_match(1)) if @datastore['results'] =~ /^vlc=(Yes|No)/
  end
end
