require "sinatra"
require "uri"
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
      erb :show, locals: {feature: FeaturePresenter.new(feature, base_path)}
    end

    put "/feature/:name/toggle" do
      content_type :text

      if feature.update(enabled: !feature.enabled)
        204
      else
        [422, "Failed to update feature"]
      end
    end

    get "/feature/:name/entities" do
      erb :feature_entities, locals: {feature: FeaturePresenter.new(feature, base_path)}
    end

    get '/search_entity' do
      class_name = params[:class_name]
      query = URI.decode_www_form_component(params[:q])
      result = Flipside.search_entity(class_name:, query:)

      erb :_entity_search_result, locals: {result:, class_name:, query:}
    end

    post "/feature/:name/add_entity" do
      name, class_name, identifier = params.values_at("name", "class_name", "identifier")

      entity = Flipside.find_entity(class_name:, identifier:)
      Flipside.add_entity(name: , entity:)
      redirect to("/feature/#{name}/entities"), 303
    end

    post "/feature/:name/remove_entity" do
      Flipside::Entity.find(params["entity_id"]).destroy
      redirect to("/feature/#{params["name"]}/entities"), 303
    end

    get "/feature/:name/roles" do
      erb :feature_roles, locals: {feature: FeaturePresenter.new(feature, base_path)}
    end

    def feature
      @feature ||= Flipside::Feature.find_by!(name: params["name"])
    rescue
      halt 404, "This feature does not exist"
    end

    def base_path
      @base_path ||= request.script_name
    end
  end
end
