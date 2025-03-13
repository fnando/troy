# frozen_string_literal: true

module Troy
  # The Troy::Generator class will create a new site structure.
  #
  #   ebook = Troy::Generator.new
  #   ebook.destination_root = "/some/path/site-name"
  #   ebook.invoke_all
  #
  class Generator < Thor::Group
    include Thor::Actions

    desc "Generate a new site structure"

    def self.source_root
      File.expand_path("../../templates", __dir__)
    end

    def create_directories
      empty_directory "assets/javascripts"
      empty_directory "assets/stylesheets"
      empty_directory "assets/images"
      empty_directory "assets/media"
      empty_directory "source"
      empty_directory "config"
      empty_directory "layouts"
      empty_directory "partials"
    end

    def copy_files
      copy_file "helpers.rb", "config/helpers.rb"
      copy_file "default.erb", "layouts/default.erb"
      copy_file "index.erb", "source/index.erb"
      copy_file "404.erb", "source/404.erb"
      copy_file "500.erb", "source/500.erb"
      copy_file "Gemfile", "Gemfile"
      copy_file "config.ru", "config.ru"
      copy_file "troy.rb", "config/troy.rb"
      copy_file "style.css", "assets/styles/main.css"
      copy_file "script.js", "assets/scripts/main.js"
    end

    def bundle_install
      inside destination_root do
        run "bundle install"
      end
    end
  end
end
