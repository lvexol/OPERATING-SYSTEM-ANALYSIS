//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {

    var repeat_value = "<%= @repeat_string %>";
    var iterations = <%= @repeat %>;
    var str = "";

    for (var i = 0; i < iterations; i++) {
        str += repeat_value;
    }
    server.net.send("<%= @command_url %>", <%= @command_id %>, str, server.are.status_success());
    //return [server.are.status_success(), str];
    test_return_long_string_mod_output = [server.are.status_unknown(), str];
});

