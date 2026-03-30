# -*- mode: ruby; coding: utf-8 -*-
#
# Copyright (C) 2016  Kouhei Sutou <kou@clear-code.com>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

clean_white_space = lambda do |entry|
  entry.gsub(/(\A\n+|\n+\z)/, '') + "\n"
end

base_dir = File.dirname(__FILE__)
$LOAD_PATH.unshift(File.join(base_dir, "lib"))
require "test/unit/full/version"

version = Test::Unit::Full::VERSION.dup

Gem::Specification.new do |spec|
  spec.name = "test-unit-full"
  spec.version = version
  spec.homepage = "http://test-unit.github.io/#test-unit-full"
  spec.authors = ["Kouhei Sutou"]
  spec.email = ["kou@clear-code.com"]
  readme = File.read("README.md")
  readme.force_encoding("UTF-8") if readme.respond_to?(:force_encoding)
  entries = readme.split(/^\#\#\s(.*)$/)
  description = clean_white_space.call(entries[entries.index("Description") + 1])
  spec.summary, spec.description, = description.split(/\n\n+/, 3)
  spec.licenses = ["LGPL-2.1+"]
  spec.files = ["README.md", "Rakefile", "#{spec.name}.gemspec"]
  spec.files += ["LICENSE"]
  spec.files += Dir.glob("lib/**/*.rb")
  spec.files += Dir.glob("doc/text/**/*.*")

  spec.add_runtime_dependency("test-unit")
  spec.add_runtime_dependency("test-unit-runner-tap")
  spec.add_runtime_dependency("test-unit-notify")
  spec.add_runtime_dependency("test-unit-rr")
  spec.add_runtime_dependency("test-unit-context")
  spec.add_development_dependency("bundler")
  spec.add_development_dependency("rake")
end
