module Troy
  class Cli < Thor
    check_unknown_options!

    def self.exit_on_failure?
      true
    end

    def initialize(args = [], options = {}, config = {})
      if (config[:current_task] || config[:current_command]).name == "new" && args.empty?
        raise Error, "The site path is required. For details run: troy help new"
      end

      super
    end

    options assets: :boolean, file: :string
    desc "export", "Export files"
    def export
      if options[:assets]
        site.export_assets
      elsif options[:file]
        site.export_pages(options[:file])
      else
        site.export
      end
    end

    desc "new SITE", "Generate a new site structure"
    def new(path)
      generator = Generator.new
      generator.destination_root = path
      generator.invoke_all
    end

    desc "version", "Display Troy version"
    map %w(-v --version) => :version
    def version
      say "Troy #{Troy::VERSION}"
    end

    desc "server", "Start a server"
    option :port, :type => :numeric, :default => 9292, :aliases => "-p"
    def server
      handler = Rack::Handler::Thin rescue Rack::Handler::WEBrick
      handler.run Troy::Server.new(File.join(Dir.pwd, "public")), :Port => options[:port]
    end

    private
    def site
      @site ||= Troy::Site.new(Dir.pwd)
    end
  end
end
