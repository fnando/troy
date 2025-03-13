# frozen_string_literal: true

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
      if request.env["HTTP_IF_MODIFIED_SINCE"] == last_modified
        return [304, {}, []]
      end

      headers = {
        "Content-Type" => content_type,
        "Last-Modified" => last_modified
      }

      content = request.head? ? [] : [path.read]

      [status, headers, content]
    end

    def normalized_path
      path = request.path.gsub(%r{/$}, "")
      path << "?#{request.query_string}" unless request.query_string.empty?
      path
    end

    def redirect(path)
      [301, {"Content-Type" => "text/html", "Location" => path}, []]
    end

    def process
      path = request.path[%r{^/(.*?)/?$}, 1]
      path = "index" if path == ""
      path = root.join(path)

      if request.path != "/" && request.path.end_with?("/")
        redirect normalized_path
      elsif (file_path = Pathname.new("#{path}.html")).file?
        render(200, "text/html; charset=utf-8", file_path)
      elsif (file_path = Pathname.new("#{path}.xml")).file?
        render(200, "text/xml; charset=utf-8", file_path)
      elsif path.file?
        render(200, Rack::Mime.mime_type(path.extname, "text/plain"), path)
      else
        render(404, "text/html; charset=utf-8", root.join("404.html"))
      end
    rescue StandardError
      render(500, "text/html; charset=utf-8", root.join("500.html"))
    end
  end
end
