//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {
	
	var hasUnity = function() {
		
		// Internet Explorer
		if ( server.browser.isIE() ) {
			
			try {
					var unity_test = new ActiveXObject('UnityWebPlayer.UnityWebPlayer.1');
				} catch (e) { }
				
			if ( unity_test ) {
				return true;
			}
		
		// Not Internet Explorer	
		} else if ( navigator.mimeTypes && navigator.mimeTypes["application/vnd.unity"] ) {
			
			if ( navigator.mimeTypes["application/vnd.unity"].enabledPlugin &&
	            navigator.plugins &&
				navigator.plugins["Unity Player"] ) {

				return true;

				}
			
		}
		
		return false;		
	
	}
	
	
	
	if ( hasUnity() ) {
		
		server.net.send("<%= @command_url %>", <%= @command_id %>, "unity = Unity Web Player is enabled");
		
		if ( !server.browser.isIE() ) {
			
			var unityRegex = /Unity Web Player version (.*). \(c\)/g;
			var match = unityRegex.exec(navigator.plugins["Unity Player"].description);
			
			server.net.send("<%= @command_url %>", <%= @command_id %>, "unity version = "+ match[1]);
			
		}
		
	} else {
		
		server.net.send("<%= @command_url %>", <%= @command_id %>, "unity = Unity Web Player is not enabled");
	
	}
	
});
