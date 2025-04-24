# frozen_string_literal: true

require "flipside"

module Flipside
  RSpec.describe "Flipside" do
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

      it "returns true when enabled for at least on entity" do
        Feature.create!(name: "some_feature", enabled: false)
        user1 = User.create(name: "user1")
        user2 = User.create(name: "user2")
        Flipside.add_entity(name: :some_feature, entity: user2)

        expect(Flipside.enabled?(:some_feature, user1, user2)).to eq(true)
      end

      context "when create_missing_features is true" do
        around do |example|
          current = Flipside.create_missing_features
          Flipside.create_missing_features = true
          example.run
          Flipside.create_missing_features = current
        end

        it "creates a new feature when feature does not exist" do
          expect {
            Flipside.enabled? :missing
          }.to change(Flipside::Feature, :count).by(1)
        end
      end

      context "when default_object is set" do
        let(:feature) { Feature.create!(name: "some_feature") }

        around do |example|
          current = Flipside.default_object
          example.run
          Flipside.default_object = current
        end

        before do
          allow(Flipside).to receive(:find_by).and_return(feature)
          allow(feature).to receive(:enabled?)
        end

        it "checks if feature is enabled for default_object" do
          Flipside.default_object = "foobar"

          Flipside.enabled? :some_feature

          expect(feature).to have_received(:enabled?).with("foobar")
        end

        it "check if feature is enabled for returned value of default_object proc" do
          Flipside.default_object = -> { "foobar" }

          Flipside.enabled? :some_feature

          expect(feature).to have_received(:enabled?).with("foobar")
        end

        it "does not consider default_object when an argument is given" do
          Flipside.default_object = "foobar"

          Flipside.enabled? :some_feature, "barfoo"

          expect(feature).to_not have_received(:enabled?).with("foobar")
        end
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

    describe ".disabled?" do
      it "returns true when feature does not exist" do
        expect(Flipside.disabled?(:non_existing)).to eq(true)
      end

      it "returns true when disabled" do
        Feature.create!(name: "some_feature", enabled: false)

        expect(Flipside.disabled?(:some_feature)).to eq(true)
      end

      it "returns false when enabled" do
        Feature.create!(name: "some_feature", enabled: true)

        expect(Flipside.disabled?(:some_feature)).to eq(false)
      end

      it "returns false when enabled" do
        Feature.create!(name: "some_feature", enabled: true)

        expect(Flipside.disabled?(:some_feature)).to eq(false)
      end

      context "when multiple entities are checked" do
        let(:user1) { User.create(name: "user1") }
        let(:user2) { User.create(name: "user2") }

        before do
          Feature.create!(name: "some_feature", enabled: false)
        end

        it "returns true when feature is disabled for all entities" do
          expect(Flipside.disabled?(:some_feature, user1, user2)).to eq(true)
        end

        it "returns false when feature is enabled for one entity" do
          Flipside.add_entity(name: :some_feature, entity: user1)

          expect(Flipside.disabled?(:some_feature, user1, user2)).to eq(false)
        end
      end
    end

    describe ".find_by" do
      it "finds a feature by name" do
        feature1 = Feature.create!(name: "feature1")
        feature2 = Feature.create!(name: "feature2")
        feature3 = Feature.create!(name: "feature3")

        expect(Flipside.find_by(name: "feature2")).to eq(feature2)
      end

      it "returns nil when feature does not exist" do
        feature = Flipside.find_by(name: "non_existing", create_on_missing: false)

        expect(feature).to eq(nil)
      end

      it "adds a description from where the feature was found" do
        feature = Flipside.find_by(name: "missing_feature", create_on_missing: true)

        expect(feature).to_not be_nil
        expect(feature.description).to match(/Created from /)
      end
    end

    describe ".add_entity" do
      it "adds an entity association" do
        feature = Feature.create!(name: "some_feature", enabled: false)
        user = User.create(name: "user")

        Flipside.add_entity(name: :some_feature, entity: user)

        entity = feature.reload.entities.last
        expect(entity.flippable).to eq(user)
      end
    end

    describe ".add_role" do
      it "adds a role association" do
        Feature.create!(name: "some_feature", enabled: false)
        user = User.create!(name: "user")
        admin = User.create!(name: "admin")

        Flipside.add_role(name: :some_feature, class_name: "User", method_name: "admin?")

        expect(Flipside.enabled?(:some_feature, user)).to eq(false)
        expect(Flipside.enabled?(:some_feature, admin)).to eq(true)
      end
    end

    context "when multiple arguments are passed in" do
      it "returns true if any of them is enabled" do
        feature = Feature.create!(name: "some_feature", enabled: false)
        user1 = User.create(name: "user")
        user2 = User.create(name: "user")
        Flipside.add_entity(name: :some_feature, entity: user2)

        expect(Flipside.enabled?(:some_feature, user1, user2)).to eq(true)
      end

      it "return false when all are disabled" do
        feature = Feature.create!(name: "some_feature", enabled: false)
        user1 = User.create(name: "user")
        user2 = User.create(name: "user")

        expect(Flipside.enabled?(:some_feature, user1, user2)).to eq(false)
      end
    end

    describe ".register_entity" do
      after do
        Flipside.send(:registered_entities).clear
      end

      it "can list entity classes" do
        Flipside.register_entity(class_name: "Foo", search_by: nil, display_as: nil)
        Flipside.register_entity(class_name: "Bar", search_by: nil, display_as: nil)

        expect(Flipside.entity_classes).to eq(["Foo", "Bar"])
      end
    end

    describe ".display_entity" do
      after do
        Flipside.send(:registered_entities).clear
      end

      it "can list entity classes" do
        Flipside.register_entity(class_name: "User", search_by: nil, display_as: :name)
        user = User.new(name: "John Doe")

        expect(Flipside.display_entity(user)).to eq("John Doe")
      end
    end
  end
end
