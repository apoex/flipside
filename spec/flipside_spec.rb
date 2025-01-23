# frozen_string_literal: true

require "flipside"

module Flipside
  RSpec.describe "Flipside" do
    it "has a version number" do
      expect(Flipside::VERSION).not_to be nil
    end

    describe ".enabled?" do
      it "returns false when feature does not exist" do
        expect(Flipside.enabled?(:non_existing)).to eq(false)
      end

      it "returns false when disabled" do
        Feature.create!(name: "some_feature", enabled: false)

        expect(Flipside.enabled?(:some_feature)).to eq(false)
      end

      it "returns true when enabled" do
        Feature.create!(name: "some_feature", enabled: true)

        expect(Flipside.enabled?(:some_feature)).to eq(true)
      end
    end

    describe ".enabled!" do
      it "enables the feature" do
        feature = Feature.create!(name: "some_feature", enabled: false)

        Flipside.enable! :some_feature

        expect(feature.reload.enabled).to eq(true)
      end

      it "raises an exception when feature does not exist" do
        expect {
          Flipside.enable! :non_existing
        }.to raise_error(NoSuchFeauture)
      end
    end

    describe ".add_entity" do
      let(:user_class) do
        Class.new(ActiveRecord::Base) do
          has_many :features, class_name: "Flipside::EntityFeature", dependent: :destroy
        end
      end

      before do
        stub_const("User", user_class)
        ActiveRecord::Base.connection.create_table :users, force: true do |t|
          t.string(:name)
        end
      end

      after do
        ActiveRecord::Base.connection.drop_table(:users, if_exists: true)
      end

      it "adds an entity association" do
        feature = Feature.create!(name: "some_feature", enabled: false)
        user = User.create(name: "user")

        Flipside.add_entity(name: :some_feature, entity: user)

        entity = feature.reload.entities.last
        expect(entity.flippable).to eq(user)
      end
    end

    describe ".add_role" do
      let(:user_class) do
        Class.new(ActiveRecord::Base) do
          has_many :features, class_name: "Flipside::EntityFeature", dependent: :destroy

          def admin?
            name == "admin"
          end
        end
      end

      before do
        stub_const("User", user_class)
        ActiveRecord::Base.connection.create_table :users, force: true do |t|
          t.string(:name)
        end
      end

      after do
        ActiveRecord::Base.connection.drop_table(:users, if_exists: true)
      end

      it "adds a role association" do
        Feature.create!(name: "some_feature", enabled: false)
        user = User.create!(name: "user")
        admin = User.create!(name: "admin")

        Flipside.add_role(name: :some_feature, class_name: "User", method: "admin?")

        expect(Flipside.enabled?(:some_feature, user)).to eq(false)
        expect(Flipside.enabled?(:some_feature, admin)).to eq(true)
      end
    end

    describe ".add_key" do
      it "adds a value" do
        Feature.create!(name: "some_feature", enabled: false)

        Flipside.add_key(name: :some_feature, key: "foo")

        expect(Flipside.enabled?(:some_feature, "foo")).to eq(true)
        expect(Flipside.enabled?(:some_feature, "bar")).to eq(false)
      end
    end

    describe ".register_entity" do
      after do
        Flipside.send(:entities).clear
      end

      it "can list entity classes" do
        Flipside.register_entity(class_name: "Foo", search_by: nil, display_as: nil)
        Flipside.register_entity(class_name: "Bar", search_by: nil, display_as: nil)

        expect(Flipside.entity_classes).to eq(["Foo", "Bar"])
      end

      it "can list entity classes" do
      end
    end
  end
end
