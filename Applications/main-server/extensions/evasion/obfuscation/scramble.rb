#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Extension
    module Evasion
      class Scramble
        include Singleton

        def need_bootstrap?
          false
        end

        def execute(input, config)
          @output = input

          to_scramble = config.get('server.extension.evasion.scramble')
          to_scramble.each do |var, value|
            if var == value
              # Variables have not been scrambled yet
              mod_var = Server::Core::Crypto.random_alphanum_string(3)
              @output.gsub!(var, mod_var)
              config.set("server.extension.evasion.scramble.#{var}", mod_var)
              print_debug "[OBFUSCATION - SCRAMBLER] string [#{var}] scrambled -> [#{mod_var}]"
            else
              # Variables already scrambled, re-use the one already created to maintain consistency
              @output.gsub!(var, value)
              print_debug "[OBFUSCATION - SCRAMBLER] string [#{var}] scrambled -> [#{value}]"
            end
            @output
          end

          if config.get('server.extension.evasion.scramble_cookies')
            # ideally this should not be static, but it's static in JS code, so fine for nowend
            mod_cookie = Server::Core::Crypto.random_alphanum_string(5)
            if config.get('server.http.hook_session_name') == 'SERVERHOOK'
              @output.gsub!('SERVERHOOK', mod_cookie)
              config.set('server.http.hook_session_name', mod_cookie)
              print_debug "[OBFUSCATION - SCRAMBLER] cookie [SERVERHOOK] scrambled -> [#{mod_cookie}]"
            else
              @output.gsub!('SERVERHOOK', config.get('server.http.hook_session_name'))
              print_debug "[OBFUSCATION - SCRAMBLER] cookie [SERVERHOOK] scrambled -> [#{config.get('server.http.hook_session_name')}]"
            end
          end

          @output
        end
      end
    end
  end
end
