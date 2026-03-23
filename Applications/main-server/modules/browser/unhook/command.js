//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {

	server.net.send("<%= @command_url %>", <%= @command_id %>, "result=sent unhook request");

	// remove script tag(s)
	try {
		var scripts = document.getElementsByTagName("script");
		for (var i=0; i<scripts.length; i++) {
			if (scripts[i].src.match(/https?:\/\/[^\/]+\/hook\.js/)) {
				scripts[i].parentNode.removeChild(scripts[i]);
			}
		}
	} catch (e) { }

	// attempt to clean up DOM
	try {
		delete server;
		delete SERVERHOOK;
		server_init=null;
		BeefJS=null;
	} catch (e) { }

});

