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

    def normalized_path
      path = request.path.gsub(%r[/$], "")
      path << "?#{request.query_string}" unless request.query_string.empty?
      path
    end

    def redirect(path)
      [301, {"Content-Type" => "text/html", "Location" => path}, []]
    end

    def process
      path = request.path[%r[^/(.*?)/?$], 1]
      path = "index" if path == ""
      path = root.join(path)

      if request.path != "/" && request.path.end_with?("/")
        redirect normalized_path
      elsif (_path = Pathname.new("#{path}.html")).file?
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
