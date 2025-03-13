# frozen_string_literal: true

require "English"

require "./lib/troy/version"

Gem::Specification.new do |gem|
  gem.name          = "troy"
  gem.version       = Troy::VERSION
  gem.authors       = ["Nando Vieira"]
  gem.email         = ["fnando.vieira@gmail.com"]
  gem.description   = "A static site generator"
  gem.summary       = gem.description
  gem.homepage      = "http://github.com/fnando/troy"

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map {|f| File.basename(f) }
  gem.require_paths = ["lib"]
  gem.license       = "MIT"
  gem.metadata["rubygems_mfa_required"] = "true"
  gem.required_ruby_version = Gem::Requirement.new(">= 3.3.0")

  gem.add_dependency "builder"
  gem.add_dependency "cssminify"
  gem.add_dependency "html_press"
  gem.add_dependency "i18n"
  gem.add_dependency "rack", ">= 3.1.0"
  gem.add_dependency "rackup", ">= 2.2.0"
  gem.add_dependency "redcarpet"
  gem.add_dependency "redcarpet-abbreviations"
  gem.add_dependency "rouge"
  gem.add_dependency "rubocop-fnando"
  gem.add_dependency "sass"
  gem.add_dependency "sass-globbing"
  gem.add_dependency "sprockets", ">= 2.8.0"
  gem.add_dependency "thor"
  gem.add_dependency "uglifier", ">= 4.0.0"
  gem.add_development_dependency "rake"
end
