#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
module Server
  module Extension
    module Qrcode
      module QrcodeGenerator
        Server::API::Registrar.instance.register(Server::Extension::Qrcode::QrcodeGenerator, Server::API::HttpServer, 'pre_http_start')

        def self.pre_http_start(_http_hook_server)
          require 'uri'
          require 'qr4r'

          fullurls = []

          # get server config
          configuration = Server::Core::Configuration.instance
          server_proto = configuration.server_proto
          server_host  = configuration.server_host
          server_port  = configuration.server_port

          # get URLs from QR config
          configuration.get('server.extension.qrcode.targets').each do |target|
            # absolute URLs
            if target.lines.grep(%r{^https?://}i).size.positive?
              fullurls << target
            # relative URLs
            else
              
              # Retrieve the list of network interfaces from Server::Core::Console::Banners
              interfaces = Server::Core::Console::Banners.interfaces

              if not interfaces.nil? and not interfaces.empty? # If interfaces are available, iterate over each network interface
                # If interfaces are available, iterate over each network interface
                interfaces.each do |int|
                  # Skip the loop iteration if the interface address is '0.0.0.0' (which generally represents all IPv4 addresses on the local machine)
                  next if int == '0.0.0.0'
                  # Construct full URLs using the network interface address, and add them to the fullurls array
                  # The URL is composed of the Server protocol, interface address, Server port, and the target path
                  fullurls << "#{server_proto}://#{int}:#{server_port}#{target}"
                end
              end

            end
          end

          return unless fullurls.empty?

          img_dir = 'extensions/qrcode/images'
          begin
            Dir.mkdir(img_dir) unless File.directory?(img_dir)
          rescue StandardError
            print_error "[QR] Could not create directory '#{img_dir}'"
          end

          data = ''
          fullurls.uniq.each do |target|
            fname = ('a'..'z').to_a.sample(8).join
            qr_path = "#{img_dir}/#{fname}.png"
            begin
              Qr4r.encode(
                target, qr_path, {
                  pixel_size: configuration.get('server.extension.qrcode.qrsize'),
                  border: configuration.get('server.extension.qrcode.qrborder')
                }
              )
            rescue StandardError
              print_error "[QR] Could not write file '#{qr_path}'"
              next
            end

            print_debug "[QR] Wrote file '#{qr_path}'"
            Server::Core::NetworkStack::Handlers::AssetHandler.instance.bind(
              "/#{qr_path}", "/qrcode/#{fname}", 'png'
            )

            data += "#{server_proto}://#{server_host}:#{server_port}/qrcode/#{fname}.png\n"
            data += "- URL: #{target}\n"
            # Google API
            # url = URI::Parser.new.escape(target,Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
            # w = configuration.get("server.extension.qrcode.qrsize").to_i * 100
            # h = configuration.get("server.extension.qrcode.qrsize").to_i * 100
            # data += "- Google API: https://chart.googleapis.com/chart?cht=qr&chs=#{w}x#{h}&chl=#{url}\n"
            # QRServer.com
            # url = URI::Parser.new.escape(target,Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
            # w = configuration.get("server.extension.qrcode.qrsize").to_i * 100
            # h = configuration.get("server.extension.qrcode.qrsize").to_i * 100
            # data += "- QRServer API: https://api.qrserver.com/v1/create-qr-code/?size=#{w}x#{h}&data=#{url}\n"
          end

          print_info 'QR code images available:'
          print_more data
        end
      end
    end
  end
end
