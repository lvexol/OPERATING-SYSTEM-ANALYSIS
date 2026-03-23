#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Detect_evernote_clipper < Server::Core::Command
  def post_execute
    content = {}
    content['evernote_clipper'] = @datastore['evernote_clipper'] unless @datastore['evernote_clipper'].nil?
    save content
  end
end
