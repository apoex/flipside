# frozen_string_literal: true

module Flipside
  RSpec.describe Flippable, type: :model do
    let(:user_class) do
      Class.new(ActiveRecord::Base) do
        include Flipside::Flippable
      end
    end

    let(:feature) { Feature.create!(name: "some_feature") }

    before do
      stub_const("User", user_class)
      ActiveRecord::Base.connection.create_table :users, force: true do |t|
        t.string(:name)
      end
    end

    after do
      ActiveRecord::Base.connection.drop_table(:users, if_exists: true)
    end

    it "removes the entities of a destroyed record" do
      user = User.create!(name: "John Doe")
      other_user = User.create!(name: "Jane Doe")
      Entity.create!(feature:, flippable: user)
      other_entity = Entity.create!(feature:, flippable: other_user)

      user.destroy

      expect(Entity.all).to eq([other_entity])
    end
  end
end
