# -*- encoding: utf-8 -*-
# stub: qr4r 0.6.2 ruby lib

Gem::Specification.new do |s|
  s.name = "qr4r".freeze
  s.version = "0.6.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "rubygems_mfa_required" => "true" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Jon Rogers".freeze]
  s.date = "2023-04-23"
  s.description = "QR PNG Generator for Ruby. Leveraging RQRCode and MojoMagick modules".freeze
  s.email = ["jon@rcode5.com".freeze]
  s.homepage = "http://github.com/rcode5/qr4r".freeze
  s.licenses = ["WTFPL".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.5.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "qr4r-0.6.2".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<mojo_magick>.freeze, ["~> 0.6.5"])
  s.add_runtime_dependency(%q<rqrcode_core>.freeze, ["~> 1.0"])
  s.add_development_dependency(%q<minitest>.freeze, ["~> 5.14"])
  s.add_development_dependency(%q<rake>.freeze, ["~> 13.0"])
  s.add_development_dependency(%q<rubocop>.freeze, ["~> 1.0"])
  s.add_development_dependency(%q<rubocop-performance>.freeze, ["~> 1.8"])
end
