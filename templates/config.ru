require "bundler"
Bundler.setup(:production)
Bundler.require

require "troy"

app = Rack::Builder.app do
  use Rack::ContentLength
  use Rack::CommonLogger
  run Troy::Server.new(File.expand_path("../public", __FILE__))
end

run app
