//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {
  try {
    server.debug("Clearing console...");
    console.clear();
    server.net.send("<%= @command_url %>", <%= @command_id %>, "result=cleared console", server.are.status_success());
  } catch(e) {
    server.net.send("<%= @command_url %>", <%= @command_id %>, "fail=could not clear console", server.are.status_error());
  }
});
