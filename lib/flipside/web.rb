require "sinatra"
require "flipside/feature_presenter"

module Flipside
  class Web < Sinatra::Base
    not_found do
      erb :not_found
    end

    get "/" do
      features = Flipside::Feature.order(:name).map do |feature|
        FeaturePresenter.new(feature, base_path)
      end

      erb :index, locals: {features:}
    end

    get "/feature/:name" do
      halt 404 unless feature
      erb :show, locals: {feature:, base_path:}
    end

    put "/feature/:name/toggle" do
      halt 404 unless feature
      if feature.nil?
        [404, {"Content-Type": "text/plain"}, "This feature does not exist"]
      elsif feature.update(enabled: !feature.enabled)
        [204, {"Content-Type": "text/plain"}, '"ok"']
      else
        [422, {"Content-Type": "text/plain"}, "Failed to update feature"]
      end
    end

    def feature
      @feature ||= Flipside::Feature.find_by(name: params["name"])
    end

    def base_path
      @base_path ||= request.script_name
    end
  end
end
