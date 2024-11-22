# frozen_string_literal: true

module Flipside
  RSpec.describe Feature, type: :model do
    it "works" do
      feature = Feature.create!(name: "new_feature", enabled: true)

      expect(feature.name).to eq("new_feature")
      expect(feature.enabled).to be true
    end

    describe "active" do
      it "is only active inside activation period" do
        start = Time.now
        activated_at = start + 3600
        deactivated_at = start + 3600 * 3

        feature = Feature.build(
          name: "activation_feature",
          enabled: true,
          activated_at:,
          deactivated_at:
        )

        expect(feature.enabled?).to eq(false)

        Timecop.travel(start + 3600 * 2)
        expect(feature.enabled?).to eq(true)

        Timecop.travel(start + 3600 * 4)
        expect(feature.enabled?).to eq(false)
      ensure
        Timecop.return
      end
    end
  end
end
