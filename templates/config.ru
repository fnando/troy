# frozen_string_literal: true

require "bundler/setup"
require "troy"

use Rack::ContentLength
use Rack::CommonLogger
use Rack::Deflater
run Troy::Server.new(File.expand_path("public", __dir__))
