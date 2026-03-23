#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Core
    module Handlers
      class Commands
        include Server::Core::Handlers::Modules::ServerJS
        include Server::Core::Handlers::Modules::Command

        @data = {}

        #
        # Handles command data
        #
        # @param [Hash] data Data from command execution
        # @param [Class] kclass Class of command
        #
        # @todo Confirm argument data variable type [radoen]: type is Hash confirmed.
        #
        def initialize(data, kclass)
          @kclass = Server::Core::Command.const_get(kclass.capitalize)
          @data = data
          setup
        end

        #
        # @note Initial setup function, creates the command module and saves details to datastore
        #
        def setup
          @http_params = @data['request'].params
          @http_header = {}
          http_header = @data['request'].env.select { |k, _v| k.to_s.start_with? 'HTTP_' }.each do |key, value|
            @http_header[key.sub(/^HTTP_/, '')] = value.force_encoding('UTF-8')
          end

          # @note get and check command id from the request
          command_id = get_param(@data, 'cid')
          unless command_id.is_a?(Integer)
            print_error("Command ID is invalid")
            return
          end

          # @note get and check session id from the request
          serverhook = get_param(@data, 'serverhook')
          unless Server::Filters.is_valid_hook_session_id?(serverhook)
            print_error 'Server hook session ID is invalid'
            return
          end

          result = get_param(@data, 'results')

          # @note create the command module to handle the response
          command = @kclass.new(Server::Module.get_key_by_class(@kclass))
          command.build_callback_datastore(result, command_id, serverhook, @http_params, @http_header)
          command.session_id = serverhook
          command.post_execute if command.respond_to?(:post_execute)

          # @todo this is the part that store result on db and the modify
          # will be accessible from all the framework and so UI too
          # @note get/set details for datastore and log entry
          command_friendly_name = command.friendlyname
          if command_friendly_name.empty?
            print_error 'command friendly name is empty'
            return
          end

          command_status = @data['status']
          unless command_status.is_a?(Integer)
            print_error 'command status is invalid'
            return
          end

          command_results = @data['results']
          if command_results.empty?
            print_error 'command results are empty'
            return
          end

          # @note save the command module results to the datastore and create a log entry
          command_results = { 'data' => command_results }
          Server::Core::Models::Command.save_result(
            serverhook,
            command_id,
            command_friendly_name,
            command_results,
            command_status
          )
        end

        #
        # @note Returns parameter from hash
        #
        # @param [Hash] query Hash of data to return data from
        # @param [String] key Key to search for and return inside `query`
        #
        # @return Value referenced in hash at the supplied key
        #
        def get_param(query, key)
          return unless query.instance_of?(Hash)
          return unless query.key?(key)

          query[key]
        end
      end
    end
  end
end
