module HtmlPress
  def self.js_compressor (text, options = nil)
    options ||= {}
    options[:output] ||= {:inline_script => true}
    MultiJs.compile(text, options).gsub(/;$/,'')
  end
end
