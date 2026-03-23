#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Get_internal_ip_java < Server::Core::Command
  def pre_send
    Server::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/host/get_internal_ip_java/get_internal_ip.class', '/get_internal_ip', 'class')
  end

  # def self.options
  #  return [
  #      { 'name' => 'applet_name', 'description' => 'Applet Name', 'ui_label'=>'Number', 'value' =>'5551234','width' => '200px' },
  #  ]
  # end

  def post_execute
    content = {}
    content['Result'] = @datastore['result']
    save content
    Server::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/get_internal_ip.class')

    configuration = Server::Core::Configuration.instance
    return unless configuration.get('server.extension.network.enable') == true

    session_id = @datastore['serverhook']

    # save the network host
    return unless @datastore['results'] =~ /^([\d.]+)$/

    ip = Regexp.last_match(1)
    if Server::Filters.is_valid_ip?(ip)
      print_debug("Hooked browser has network interface #{ip}")
      Server::Core::Models::NetworkHost.create(hooked_browser_id: session_id, ip: ip)
    end
  end
end
