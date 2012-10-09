module Troy
  class Server
    attr_reader :root, :request

    def initialize(root)
      @root = Pathname.new(root)
    end

    def call(env)
      @request = Rack::Request.new(env)
      process
    end

    def render(status, content_type, path)
      last_modified = path.mtime.httpdate
      return [304, {}, []] if request.env["HTTP_IF_MODIFIED_SINCE"] == last_modified

      headers = {
        "Content-Type" => content_type,
        "Last-Modified" => last_modified
      }

      content = request.head? ? [] : [path.read]

      [status, headers, content]
    end

    def process
      path = request.path
      path = "index" if path == "/"
      path = root.join(path.gsub(%r[^/], ""))

      if (_path = Pathname.new("#{path}.html")).file?
        render(200, "text/html", _path)
      elsif (_path = Pathname.new("#{path}.xml")).file?
        render(200, "text/xml", _path)
      elsif path.file? && path.extname !~ /\.(html?|xml)$/
        render(200, Rack::Mime.mime_type(path.extname, "text/plain"), path)
      else
        render(404, "text/html", root.join("404.html"))
      end
    rescue Exception => error
      render(500, "text/html", root.join("500.html"))
    end
  end
end
