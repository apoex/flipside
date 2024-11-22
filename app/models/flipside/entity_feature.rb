# frozen_string_literal: true

require_relative "base_feature"

module Flipside
  class EntityFeature < BaseFeature
    has_many :entities, foreign_key: :feature_id

    def enabled?(entity)
      return false unless super()

      entities.where(flippable: entity).exists?
    end
  end
end
