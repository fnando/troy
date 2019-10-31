# frozen_string_literal: true

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

    options assets: :boolean, file: :array
    option :concurrency, type: :numeric, default: 10
    option :benchmark, type: :boolean, default: false
    desc "export", "Export files"
    def export
      runner = lambda do
        if options[:assets]
          site.export_assets
          site.export_files
        end

        options[:file]&.each do |file|
          site.export_pages(file)
        end

        site.export if !options[:assets] && !options[:file]
      end

      if options[:benchmark]
        require "benchmark"
        elapsed = Benchmark.realtime(&runner)
        puts "=> Finished in #{elapsed.round(2)}s"
      else
        runner.call
      end
    end

    desc "new SITE", "Generate a new site structure"
    def new(path)
      generator = Generator.new
      generator.destination_root = path
      generator.invoke_all
    end

    desc "version", "Display Troy version"
    map %w[-v --version] => :version
    def version
      say "Troy #{Troy::VERSION}"
    end

    desc "server", "Start a server"
    option :port, type: :numeric, default: 9292, aliases: "-p"
    option :host, type: :string, default: "0.0.0.0", aliases: "-b"
    def server
      begin
        handler = Rack::Handler::Thin
        Thin::Logging.level = Logger::DEBUG
      rescue Exception
        handler = Rack::Handler::WEBrick
      end

      handler.run Troy::Server.new(File.join(Dir.pwd, "public")), Port: options[:port], Host: options[:host]
    end

    no_commands do
      def site
        @site ||= Troy::Site.new(Dir.pwd, options)
      end
    end
  end
end
