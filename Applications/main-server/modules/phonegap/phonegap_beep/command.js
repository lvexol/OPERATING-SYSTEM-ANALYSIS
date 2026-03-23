//
// Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

// make the phone beep
//
server.execute(function() {
    navigator.notification.beep(1);
    server.net.send("<%= @command_url %>", <%= @command_id %>, 'Beeped');
});
