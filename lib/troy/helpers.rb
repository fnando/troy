module Troy
  module Helpers
    def h(content)
      CGI.escapeHTML(content)
    end
  end
end
