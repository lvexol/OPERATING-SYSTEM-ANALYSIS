#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Hta_powershell < Server::Core::Command
  def self.options
    @config = Server::Core::Configuration.instance
    ps_url = @config.get('server.extension.social_engineering.powershell.powershell_handler_url')

    [
      { 'name' => 'domain', 'ui_label' => 'Serving Domain (Server server)', 'value' => @config.server_url_str },
      { 'name' => 'ps_url', 'ui_label' => 'Powershell/HTA handler', 'value' => ps_url }
    ]
  end

  def post_execute
    save({ 'result' => @datastore['result'] })
  end
end
