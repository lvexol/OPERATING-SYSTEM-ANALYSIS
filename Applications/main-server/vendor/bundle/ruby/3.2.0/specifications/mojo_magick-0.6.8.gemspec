# -*- encoding: utf-8 -*-
# stub: mojo_magick 0.6.8 ruby lib

Gem::Specification.new do |s|
  s.name = "mojo_magick".freeze
  s.version = "0.6.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "rubygems_mfa_required" => "true" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Steve Midgley".freeze, "Elliot Nelson".freeze, "Jon Rogers".freeze]
  s.date = "2023-04-23"
  s.description = "Simple Ruby stateless module interface to imagemagick.".freeze
  s.email = ["science@misuse.org".freeze, "jon@rcode5.com".freeze]
  s.homepage = "http://github.com/rcode5/mojo_magick".freeze
  s.licenses = ["MIT".freeze]
  s.post_install_message = "\nThanks for installing MojoMagick - keepin it simple!\n\n*** To make this gem work, you need a few binaries!\nMake sure you've got ImageMagick available.  http://imagemagick.org\nIf you plan to build images with text (using the \"label\" method) you'll need freetype and ghostscript as well.\nCheck out http://www.freetype.org and http://ghostscript.com respectively for installation info.\n\n".freeze
  s.required_ruby_version = Gem::Requirement.new(">= 2.6.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "mojo_magick-0.6.8".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version
end
