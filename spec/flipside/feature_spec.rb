# frozen_string_literal: true

module Flipside
  RSpec.describe Feature, type: :model do
    it "is enabled" do
      feature = Feature.build(name: "new_feature", enabled: true)

      expect(feature.name).to eq("new_feature")
      expect(feature.enabled).to be true
    end

    it "is not enabled" do
      feature = Feature.build(name: "new_feature", enabled: false)

      expect(feature.name).to eq("new_feature")
      expect(feature.enabled).to be false
    end

    it "is enabled when activation period has no beginning" do
      feature = Feature.build(
        name: "activation_feature",
        enabled: true,
        activated_at: nil,
        deactivated_at: Time.now + 3600
      )

      expect(feature.enabled?).to eq(true)
    end

    it "is enabled when activation period has no end" do
      feature = Feature.build(
        name: "activation_feature",
        enabled: true,
        activated_at: Time.now,
        deactivated_at: nil
      )

      expect(feature.enabled?).to eq(true)
    end

    it "is not enabled before activation period" do
      feature = Feature.build(
        name: "activation_feature",
        enabled: true,
        activated_at: Time.now + 3600
      )

      expect(feature.enabled?).to eq(false)
    end

    it "is not enabled before activation period" do
      feature = Feature.build(
        name: "activation_feature",
        enabled: true,
        deactivated_at: Time.now - 3600
      )

      expect(feature.enabled?).to eq(false)
    end
  end
end
