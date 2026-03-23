#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#

module Server
  module Core
    # @note This class migrates and updates values in the database each time you restart Server.
    #       So for example, when you want to add a new command module, you stop Server,
    #       copy your command module into the framework and then restart Server.
    #       That class will take care of installing automatically the new command module in the db.
    class Migration
      include Singleton

      #
      # Updates the database.
      #
      def update_db!
        update_commands!
      end

      #
      # Checks for new command modules and updates the database.
      #
      def update_commands!
        config = Server::Core::Configuration.instance

        db_modules = Server::Core::Models::CommandModule.all.pluck(:name)

        config.get('server.module').each do |k, v|
          Server::Core::Models::CommandModule.new(name: k, path: "#{v['path']}module.rb").save! unless db_modules.include? k
        end

        Server::Core::Models::CommandModule.all.each do |mod|
          unless config.get("server.module.#{mod.name}").nil?
            config.set "server.module.#{mod.name}.db.id", mod.id
            config.set "server.module.#{mod.name}.db.path", mod.path
          end
        end

        # Call Migration method
        Server::API::Registrar.instance.fire Server::API::Migration, 'migrate_commands'
      end
    end
  end
end
