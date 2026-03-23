#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Fetch_port_scanner < Server::Core::Command
  # set and return all options for this module
  def self.options
    [
      { 'name' => 'ipHost', 'ui_label' => 'Scan IP or Hostname', 'value' => '127.0.0.1' },
      { 'name' => 'ports', 'ui_label' => 'Specific port(s) to scan', 'value' => 'top' }
    ]
  end

  def post_execute
    content = {}
    content['result'] = @datastore['result']
    save content

    configuration = Server::Core::Configuration.instance
    return unless configuration.get('server.extension.network.enable') == true

    session_id = @datastore['serverhook']

    # @todo log the network service
    # will need to once the datastore is confirmed.
    # This should basically try and hook the browser
  end
end
