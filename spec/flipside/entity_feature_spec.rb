# frozen_string_literal: true

module Flipside
  RSpec.describe EntityFeature, type: :model do
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

    it "works" do
      non_special_user = User.create(name: "non_special")
      special_user = User.create(name: "special")

      feature = EntityFeature.create!(
        name: "some_feature",
        description: "Special users only",
        enabled: true
      )

      Entity.create(feature:, flippable: special_user)

      expect(feature.enabled?(non_special_user)).to eq(false)
      expect(feature.enabled?(special_user)).to eq(true)
    end
  end
end
