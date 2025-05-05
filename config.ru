require_relative "config/database"
require 'flipside'

if ENV["FLIPSIDE_WEB_NEW"].to_i == 1
  run Flipside::Web2
else
  run Flipside::Web
end
