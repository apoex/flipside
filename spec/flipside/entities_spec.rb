# frozen_string_literal: true

module Flipside
  RSpec.describe Entities, type: :model do
    let(:user_class) do
      Class.new(ActiveRecord::Base) do
        has_many :features, class_name: "Flipside::EntityFeature", dependent: :destroy
      end
    end

    let(:feature) do
      Feature.create!(
        name: "some_feature",
        description: "Special users only",
        enabled: false
      )
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

    it "is enabled when user is special" do
      special_user = User.create(name: "special")
      non_special_user = User.create(name: "non_special")
      Entity.create(feature:, flippable: special_user)

      expect(feature.enabled?(special_user)).to eq(true)
    end

    it "is not enabled when user is not special" do
      special_user = User.create(name: "special")
      non_special_user = User.create(name: "non_special")
      Entity.create(feature:, flippable: special_user)

      expect(feature.enabled?(non_special_user)).to eq(false)
    end

    it "is not enabled when no user is given" do
      special_user = User.create(name: "special")
      non_special_user = User.create(name: "non_special")
      Entity.create(feature:, flippable: special_user)

      expect(feature.enabled?).to eq(false)
    end

    it "is not enabled when the feature is inactive" do
      special_user = User.create(name: "special")
      non_special_user = User.create(name: "non_special")
      Entity.create(feature:, flippable: special_user)

      expect(feature.enabled?(special_user)).to eq(true)
    end
  end
end
