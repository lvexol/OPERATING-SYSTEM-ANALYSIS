//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {

	try {
		var msg = decodeURIComponent(server.encode.base64.decode('<%= Base64.strict_encode64(@msg) %>'));
		server.debug(msg);
		server.net.send('<%= @command_url %>', <%= @command_id %>, 'result=called the server.debug() function. Check the developer console for your debug message.');
	} catch(e) {
		server.net.send('<%= @command_url %>', <%= @command_id %>, 'result=something went wrong&error='+e.message);
	}

});
