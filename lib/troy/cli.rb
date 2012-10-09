module Troy
  class Cli < Thor
    check_unknown_options!

    def self.exit_on_failure?
      true
    end

    def initialize(args = [], options = {}, config = {})
      if config[:current_task].name == "new" && args.empty?
        raise Error, "The site path is required. For details run: troy help new"
      end

      super
    end

    desc "new SITE", "Generate a new site structure"
    def new(path)
      generator = Generator.new
      generator.destination_root = path
      generator.invoke_all
    end

    desc "export", "Generate static files"
    def export
      Troy::Site.new(Dir.pwd).export
    end

    desc "watch", "Watch and auto export site"
    def watch
      Troy::Site.new(Dir.pwd).export
    end

    desc "server", "Start a server"
    option :port, :type => :numeric, :default => 9292, :aliases => "-p"
    def server
      handler = Rack::Handler::Thin rescue Rack::Handler::WEBrick
      handler.run Troy::Server.new(File.join(Dir.pwd, "public")), :Port => options[:port]
    end
  end
end
