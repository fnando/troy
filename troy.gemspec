# -*- encoding: utf-8 -*-
require "./lib/troy/version"

Gem::Specification.new do |gem|
  gem.name          = "troy"
  gem.version       = Troy::VERSION
  gem.authors       = ["Nando Vieira"]
  gem.email         = ["fnando.vieira@gmail.com"]
  gem.description   = "A static site generator"
  gem.summary       = gem.description
  gem.homepage      = "http://github.com/fnando/troy"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.post_install_message = <<-TEXT

=> Troy's configuration file has been updated.
=> Please update it according to the new template.
=> http://fnando.me/ny

  TEXT

  gem.add_dependency "i18n"
  gem.add_dependency "thor"
  gem.add_dependency "redcarpet"
  gem.add_dependency "rouge"
  gem.add_dependency "sass"
  gem.add_dependency "sass-globbing"
  gem.add_dependency "sprockets", ">= 2.8.0"
  gem.add_dependency "uglifier"
  gem.add_dependency "rack"
  gem.add_dependency "builder"
  gem.add_dependency "html_press"
end
