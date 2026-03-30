# -*- encoding: utf-8 -*-
# stub: espeak-ruby 1.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "espeak-ruby".freeze
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "rubygems_mfa_required" => "true" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Dejan Simic".freeze]
  s.date = "2022-09-24"
  s.description = "espeak-ruby is small Ruby API for utilizing \u2018espeak\u2019 and \u2018lame\u2019 to create Text-To-Speech mp3 files".freeze
  s.email = "desimic@gmail.com".freeze
  s.homepage = "https://github.com/dejan/espeak-ruby".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.5.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "espeak-ruby is small Ruby API for utilizing \u2018espeak\u2019 and \u2018lame\u2019 to create Text-To-Speech mp3 files".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_development_dependency(%q<rake>.freeze, ["~> 13.0.6"])
  s.add_development_dependency(%q<rubocop>.freeze, ["~> 1.23"])
  s.add_development_dependency(%q<test-unit>.freeze, ["~> 3.5"])
end
