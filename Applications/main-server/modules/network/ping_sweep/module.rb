#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Ping_sweep < Server::Core::Command
  def post_execute
    content = {}
    content['result'] = @datastore['result']
    save content

    configuration = Server::Core::Configuration.instance
    return unless configuration.get('server.extension.network.enable') == true

    # log the network service
    return unless @datastore['results'] =~ /^ip=(.+)&ping=(\d+)ms$/

    ip = Regexp.last_match(1)
    # ping = Regexp.last_match(2)
    session_id = @datastore['serverhook']
    if Server::Filters.is_valid_ip?(ip)
      print_debug("Hooked browser found host #{ip}")
      Server::Core::Models::NetworkHost.create(hooked_browser_id: session_id, ip: ip)
    end
  end

  def self.options
    [
      { 'name' => 'rhosts', 'ui_label' => 'Scan IP range (C class)', 'value' => 'common' },
      { 'name' => 'threads', 'ui_label' => 'Workers', 'value' => '3' }
    ]
  end
end
