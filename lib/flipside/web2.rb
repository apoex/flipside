require 'roda'
require "uri"
require "flipside/feature_presenter"

module Flipside
  class Web2 < Roda
    route do |r|
      r.root do
        features = Flipside::Feature.order(:name).map do |feature|
          FeaturePresenter.new(feature, base_path)
        end

        erb :index, locals: {features:}
      end

      r.is "feature", String do |name|
        r.get do
          erb :show, locals: {feature: FeaturePresenter.new(feature, base_path)}
        end

        r.put do
          feature.update(params.slice("description"))

          r.redirect request.path_info, 303
        end
      end
    end
  end
end
