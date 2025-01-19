# frozen_string_literal: true

module Flipside
  RSpec.describe Keys, type: :model do
    let(:feature) do
      Feature.build(
        name: "some_feature",
        description: "Special users only",
        enabled: false
      )
    end

    it "is enabled for the correct key" do
      Key.create(feature:, key: "foobar")

      expect(feature.enabled?("foobar")).to eq(true)
    end

    it "is not enabled for other keys" do
      Key.create(feature:, key: "foobar")

      expect(feature.enabled?("barfoo")).to eq(false)
    end

    it "is not enabled when key is not given" do
      Key.create(feature:, key: "foobar")

      expect(feature.enabled?).to eq(false)
    end
  end
end
