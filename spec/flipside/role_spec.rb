# frozen_string_literal: true

module Flipside
  RSpec.describe Roles, type: :model do
    let(:user_class) do
      Class.new(ActiveRecord::Base) do
        has_many :features, class_name: "Flipside::EntityFeature", dependent: :destroy

        def special_name?
          name == "special"
        end
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
      Role.create(feature:, class_name: "User", method: "special_name?")

      expect(feature.enabled?(special_user)).to eq(true)
    end

    it "is not enabled when user is not special" do
      non_special_user = User.create(name: "non_special")
      Role.create(feature:, class_name: "User", method: "special_name?")

      expect(feature.enabled?(non_special_user)).to eq(false)
    end

    it "is not enabled when user does not respond to the method" do
      user = User.create(name: "special")
      Role.create(feature:, class_name: "User", method: "foobar?")

      expect(feature.enabled?(user)).to eq(false)
    end

    it "is not enabled when user does not respond to the method" do
      user = User.create(name: "special")
      Role.create(feature:, class_name: "User", method: "special?")

      expect(feature.enabled?).to eq(false)
    end

    it "is not enabled when the feature is inactive" do
      special_user = User.create(name: "special")
      feature.activated_at = Time.now + 3600
      Role.create(feature:, class_name: "User", method: "special_name?")

      expect(feature.enabled?(special_user)).to eq(false)
    end

    it "is not enabled when no argument is provided" do
      Role.create(feature:, class_name: "User", method: "to_s")

      expect(feature.enabled?).to eq(false)
    end
  end
end
