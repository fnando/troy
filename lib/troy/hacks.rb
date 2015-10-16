require "digest/sha1"

module HtmlPress
  CONTENT_CACHE = {}

  def self.js_compressor (text, options = nil)
    options ||= {}
    options[:output] ||= {:inline_script => true}

    hash = Digest::SHA1.hexdigest(text)
    CONTENT_CACHE[hash] ||= MultiJs.compile(text, options).gsub(/;$/,'')
    CONTENT_CACHE[hash]
  end
end
