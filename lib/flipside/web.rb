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

    put "/feature/:name" do
      feature.update(params.slice("description"))

      redirect to(request.path_info), 303
    end

    put "/feature/:name/toggle" do
      content_type :text

      if feature.update(enabled: !feature.enabled)
        204
      else
        [422, "Failed to update feature"]
      end
    end

    put "/feature/:name" do
      kwargs = params.slice("activated_at", "deactivated_at")
      feature.update(**kwargs)
      redirect to("/feature/#{params["name"]}"), 303
    end

    get "/feature/:name/entities" do
      erb :feature_entities, locals: {feature: FeaturePresenter.new(feature, base_path)}
    end

    get '/search_entity' do
      class_name = params[:class_name]
      query = URI.decode_www_form_component(params[:q])
      result = Flipside.search_entity(class_name:, query:)

      erb :_search_result, locals: {result:, class_name:, query:}
    end

    post "/feature/:name/add_entity" do
      name, class_name, identifier = params.values_at("name", "class_name", "identifier")

      entity = Flipside.find_entity(class_name:, identifier:)
      Flipside.add_entity(name: , entity:)
      redirect to("/feature/#{name}/entities"), 303
    end

    post "/feature/:name/remove_entity" do
      Flipside.remove_entity(name: params["name"], entity_id: params["entity_id"])
      redirect to("/feature/#{params["name"]}/entities"), 303
    end

    get "/feature/:name/roles" do
      erb :feature_roles, locals: {feature: FeaturePresenter.new(feature, base_path)}
    end

    get '/search_role' do
      class_name = params[:class_name]
      query = URI.decode_www_form_component(params[:q])
      result = Flipside.search_role(class_name:, query:)

      erb :_search_result, locals: {result:, class_name:, query:}
    end

    post "/feature/:name/add_role" do
      name, class_name, method_name = params.values_at("name", "class_name", "identifier")
      Flipside.add_role(name:, class_name:, method_name:)

      redirect to("/feature/#{name}/roles"), 303
    end

    post "/feature/:name/remove_role" do
      Flipside.remove_role(name: params["name"], role_id: params["role_id"])

      redirect to("/feature/#{params["name"]}/roles"), 303
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
