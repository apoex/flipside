module Flipside
  # Wires Flipside into a Rails app. Only loaded when Rails is present.
  class Railtie < ::Rails::Railtie
    # Hands Flipside's deprecator to the app, so its deprecation settings (log,
    # raise, silence) apply to Flipside's warnings too.
    initializer "flipside.deprecator" do |app|
      app.deprecators[:flipside] = Flipside.deprecator if app.respond_to?(:deprecators)
    end

    # Eager loading runs before after_initialize, so every class calling the
    # macros has registered by now. Checking here fails boot, and so CI, for a
    # misconfigured list instead of the first visit to the UI. Without eager
    # loading the check would only see whatever happens to be loaded.
    config.after_initialize do |app|
      Flipside.verify_flippables! if app.config.eager_load
    end
  end
end
