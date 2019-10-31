# frozen_string_literal: true

require "digest/sha1"

module HtmlPress
  def self.content_cache
    @content_cache ||= {}
  end

  def self.js_compressor(text, options = nil)
    options ||= {}
    options[:output] ||= {inline_script: true}

    hash = Digest::SHA1.hexdigest(text)
    content_cache[hash] ||= MultiJs.compile(text, options).gsub(/;$/, "")
    content_cache[hash]
  end
end
