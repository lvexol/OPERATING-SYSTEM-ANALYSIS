#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (Server) - https://serverproject.com
# See the file 'doc/COPYING' for copying permission
#
class Fake_evernote_clipper < Server::Core::Command
  def pre_send
    Server::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/fake_evernote_clipper/login.html', '/ev/login', 'html')
    Server::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/fake_evernote_clipper/login.css', '/ev/login', 'css')
    Server::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/fake_evernote_clipper/clipboard.png', '/ev/clipboard', 'png')
    Server::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/fake_evernote_clipper/close_login.png', '/ev/close_login', 'png')
    Server::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/fake_evernote_clipper/error-clip.png', '/ev/error-clip', 'png')
    Server::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/fake_evernote_clipper/evernote_web_clipper.png', '/ev/evernote_web_clipper', 'png')
    Server::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/fake_evernote_clipper/GothamSSm-Medium.otf', '/ev/GothamSSm-Medium', 'otf')
    Server::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/fake_evernote_clipper/GothamSSm-Bold.otf', '/ev/GothamSSm-Bold', 'otf')
    Server::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/core/main/client/lib/jquery-1.12.4.min.js', '/ev/jquery', 'js')
  end

  #
  # This method is being called when a zombie sends some
  # data back to the framework.
  #
  def post_execute
    if @datastore['meta'] == 'KILLFRAME'
      Server::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/ev/login.html')
      Server::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/ev/login.css')
      Server::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/ev/clipboard.png')
      Server::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/ev/close_login.png')
      Server::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/ev/error-clip.png')
      Server::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/ev/evernote_web_clipper.png')
      Server::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/ev/GothamSSm-Medium.otf')
      Server::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/ev/GothamSSm-Bold.otf')
      Server::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/ev/jquery.js')
    end
    content = {}
    content['result'] = @datastore['result']
    save content
  end
end
