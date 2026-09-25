# frozen_string_literal: true

require "rack/mock"

module Flipside
  RSpec.describe Web do
    let(:user_class) { Class.new(ActiveRecord::Base) }
    let(:app) { Rack::MockRequest.new(Web) }

    before do
      stub_const("User", user_class)
      ActiveRecord::Base.connection.create_table :users, force: true do |t|
        t.string(:name)
      end
      Flipside.add_registered_entity(class_name: "User", search_by: nil, display_as: :name)
    end

    after do
      ActiveRecord::Base.connection.drop_table(:users, if_exists: true)
      Flipside.send(:registered_entities).clear
    end

    describe "GET /feature/:name/entities" do
      it "lists an entity whose record has been deleted, with a way to remove it" do
        feature = Feature.create!(name: "some_feature")
        user = User.create!(name: "John Doe")
        entity = Entity.create!(feature:, flippable: user)
        user.delete

        response = app.get("/feature/some_feature/entities")

        expect(response.status).to eq(200)
        expect(response.body).to include("User ##{user.id} (deleted)")
        expect(response.body).to include(%(name="entity_id" value="#{entity.id}"))
      end
    end
  end
end
