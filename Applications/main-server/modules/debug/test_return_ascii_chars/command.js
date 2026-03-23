//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {

    var str = '';
    for (var i=32; i<=127;i++) str += String.fromCharCode(i);

    server.net.send("<%= @command_url %>", <%= @command_id %>, str, server.are.status_success());
    //return [server.are.status_success(), str];
    test_return_ascii_chars_mod_output = [server.are.status_success(), str];
});

