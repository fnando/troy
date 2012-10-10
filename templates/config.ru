require "bundler"
Bundler.setup
Bundler.require

require "troy"

use Rack::ContentLength
use Rack::CommonLogger
use Rack::Deflater
run Troy::Server.new(File.expand_path("../public", __FILE__))
