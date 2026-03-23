#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
# More info:
#	http://blog.kotowicz.net/2012/02/intro-to-chrome-addons-hacking.html
#	http://jeremiahgrossman.blogspot.fr/2006/08/i-know-what-youve-got-firefox.html
#
class Detect_extensions < Server::Core::Command
  def post_execute
    content = {}
    content['extension'] = @datastore['extension']
    save content
  end
end
