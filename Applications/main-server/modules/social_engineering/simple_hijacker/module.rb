#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Simple_hijacker < Server::Core::Command
  def self.options
    config = Server::Core::Configuration.instance
    @templates = config.get('server.module.simple_hijacker.templates')

    # Defines which domains to target
    data = []
    data.push({ 'name' => 'targets', 'description' => 'list domains you want to hijack - separed by ,', 'ui_label' => 'Targetted domains', 'value' => 'server' })

    # We'll then list all templates available
    tmptpl = []
    @templates.each do |template|
      tplpath = "#{$root_dir}/modules/social_engineering/simple_hijacker/templates/#{template}.js"
      raise "Invalid template path for command template #{template}" unless File.exist?(tplpath)

      tmptpl << [template]
    end

    data.push({ 'name' => 'choosetmpl', 'type' => 'combobox', 'ui_label' => 'Template to use', 'store_type' => 'arraystore', 'store_fields' => ['tmpl'], 'store_data' => tmptpl,
                'valueField' => 'tmpl', 'displayField' => 'tmpl', 'mode' => 'local', 'emptyText' => 'Choose a template' })

    data
  end

  #
  # This method is being called when a zombie sends some
  # data back to the framework.
  #
  def post_execute
    save({ 'answer' => @datastore['answer'] })
  end
end
