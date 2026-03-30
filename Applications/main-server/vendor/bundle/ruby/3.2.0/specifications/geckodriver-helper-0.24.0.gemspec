# -*- encoding: utf-8 -*-
# stub: geckodriver-helper 0.24.0 ruby lib

Gem::Specification.new do |s|
  s.name = "geckodriver-helper".freeze
  s.version = "0.24.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Devico Solutions".freeze]
  s.date = "2019-06-23"
  s.description = "Easy installation and use of geckodriver, that provides the HTTP API\ndescribed by the WebDriver protocol to communicate with Gecko browsers, such as Firefox.".freeze
  s.email = ["info@devico.io".freeze]
  s.executables = ["gecko_updater".freeze, "geckodriver".freeze]
  s.files = ["bin/gecko_updater".freeze, "bin/geckodriver".freeze]
  s.homepage = "https://github.com/DevicoSolutions/geckodriver-helper".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Easy installation and use of geckodriver.".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
  s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
  s.add_development_dependency(%q<http>.freeze, ["~> 3.0"])
  s.add_runtime_dependency(%q<archive-zip>.freeze, ["~> 0.7"])
end
