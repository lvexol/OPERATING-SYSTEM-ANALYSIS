#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Detect_office < Server::Core::Command
  def post_execute
    content = {}
    content['office'] = @datastore['office']
    save content
    Server::Core::Models::BrowserDetails.set(@datastore['serverhook'], 'HasOffice', Regexp.last_match(1)) if @datastore['results'] =~ /^office=Office (\d+|Xp)/
  end
end
