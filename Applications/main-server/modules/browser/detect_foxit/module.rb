#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Detect_foxit < Server::Core::Command
  def post_execute
    content = {}
    content['foxit'] = @datastore['foxit']
    save content
    Server::Core::Models::BrowserDetails.set(@datastore['serverhook'], 'HasFoxit', Regexp.last_match(1)) if @datastore['results'] =~ /^foxit=(Yes|No)/
  end
end
