module Flipside
  # Hands Flipside's deprecator to the host app, so its deprecation settings
  # (log, raise, silence) apply to Flipside's warnings too.
  class Railtie < ::Rails::Railtie
    initializer "flipside.deprecator" do |app|
      app.deprecators[:flipside] = Flipside.deprecator if app.respond_to?(:deprecators)
    end
  end
end
