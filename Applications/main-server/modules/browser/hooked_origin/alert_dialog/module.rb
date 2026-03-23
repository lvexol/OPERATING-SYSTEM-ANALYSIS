#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Alert_dialog < Server::Core::Command
  # set and return all options for this module
  def self.options
    [{
      'name' => 'text',
      'description' => 'Sends an alert dialog to the victim',
      'type' => 'textarea',
      'ui_label' => 'Alert text',
      'value' => 'Server Alert Dialog',
      'width' => '400px'
    }]
  end

  def post_execute
    content = {}
    content['User Response'] = "The user clicked the 'OK' button when presented with an alert box."
    save content
  end
end
