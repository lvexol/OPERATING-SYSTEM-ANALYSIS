#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Site_redirect_iframe < Server::Core::Command
  def self.options
    @configuration = Server::Core::Configuration.instance
    proto = @configuration.server_proto
    server_host = @configuration.server_host
    server_port = @configuration.server_port
    base_host = "#{proto}://#{server_host}:#{server_port}"

    favicon_uri = "#{base_host}/ui/media/images/favicon.ico"
    [
      { 'name' => 'iframe_title', 'description' => 'Title of the iFrame', 'ui_label' => 'New Title', 'value' => 'Server - The Browser Exploitation Framework Project',
        'width' => '200px' },
      { 'name' => 'iframe_favicon', 'description' => 'Shortcut Icon', 'ui_label' => 'New Favicon', 'value' => favicon_uri, 'width' => '200px' },

      { 'name' => 'iframe_src', 'description' => 'Source of the iFrame', 'ui_label' => 'Redirect URL', 'value' => 'https://serverproject.com/', 'width' => '200px' },
      { 'name' => 'iframe_timeout', 'description' => 'iFrame timeout', 'ui_label' => 'Timeout', 'value' => '3500', 'width' => '150px' }
    ]
  end

  # This method is being called when a hooked browser sends some
  # data back to the framework.
  #
  def post_execute
    save({ 'result' => @datastore['result'] })
  end
end
