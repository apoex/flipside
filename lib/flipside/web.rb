require 'roda'
require "uri"
require "flipside/feature_presenter"
require "flipside/importmap"
require "rack/method_override"

module Flipside
  class Web < Roda
    include Flipside::Importmap
    use Rack::MethodOverride

    opts[:add_script_name] = true

    plugin :r
    plugin :json
    plugin :halt
    plugin :path
    plugin :all_verbs
    plugin :unescape_path
    plugin :render, views: File.expand_path("views", __dir__)
    plugin :public,
           root: File.expand_path("public", __dir__),
           headers: {"Cache-Control" => "public, max-age=14400"}

    path(:public) { |name| "/#{name}" }
    path(:base, "/")
    path(:feature) do |feature, *segments, **query|
      path = "/feature/#{ERB::Util.url_encode(feature.name)}"
      path = "#{path}/#{segments.join("/")}" if segments.any?
      path = "#{path}?#{query.map { |k,v| "#{k}=#{v}" }.join("&")}" if query.keys.any?
      path
    end
    path(:search_entity, "/search_entity")
    path(:search_role, "/search_role")

    def load_feature(name)
      Flipside::Feature.find_by!(name:)
    rescue
      r.halt 404, view(:not_found)
    end

    route do |r|
      r.public

      r.root do
        features = Flipside::Feature.order(:name).map do |feature|
          FeaturePresenter.new(feature)
        end

        view :index, locals: {features:}
      end

      r.on "feature", String do |name|
        feature = load_feature(name)

        r.is do
          r.get do
            view(:show, locals: { feature: FeaturePresenter.new(feature) })
          end

          r.put do
            kwargs = r.params.slice("description", "activated_at", "deactivated_at")
            feature.update(**kwargs)
            r.redirect r.path, 303
          end

          r.delete do
            feature.destroy
            r.redirect base_path, 303
          end
        end

        r.put "toggle" do
          if feature.update(enabled: !feature.enabled)
            referer = r.env["HTTP_REFERER"]
            r.redirect (referer || feature_path(feature)), 303
          else
            response.status = 422
            "Failed to update feature"
          end
        end

        r.get "entities" do
          view(:feature_entities, locals: { feature: FeaturePresenter.new(feature) })
        end

        r.post "add_entity" do
          class_name, identifier = r.params.values_at("class_name", "identifier")
          entity = Flipside.find_entity(class_name:, identifier:)
          Flipside.add_entity(feature:, entity:)
          r.redirect feature_path(feature, "entities"), 303
        end

        r.post "remove_entity" do
          Flipside.remove_entity(feature:, entity_id: r.params["entity_id"])
          r.redirect feature_path(feature, "entities"), 303
        end

        r.get "roles" do
          view(:feature_roles, locals: { feature: FeaturePresenter.new(feature) })
        end

        r.post "add_role" do
          class_name, method_name = r.params.values_at("class_name", "identifier")
          Flipside.add_role(name:, class_name:, method_name:)
          r.redirect feature_path(feature, "roles"), 303
        end

        r.post "remove_role" do
          Flipside.remove_role(name:, role_id: r.params["role_id"])
          r.redirect feature_path(feature, "roles"), 303
        end
      end

      r.get "search_entity" do
        class_name = r.params["class_name"]
        query = URI.decode_www_form_component(r.params["q"])
        result = Flipside.search_entity(class_name:, query:)
        view(:_search_result, locals: { result:, class_name:, query: })
      end

      r.get "search_role" do
        class_name = r.params["class_name"]
        query = URI.decode_www_form_component(r.params["q"])
        result = Flipside.search_role(class_name:, query:)
        view(:_search_result, locals: { result:, class_name:, query: })
      end
    end
  end
end
