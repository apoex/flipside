# frozen_string_literal: true

require "models/flipside/entity"

module Flipside
  module Entities
    def self.included(base)
      base.has_many :entities, foreign_key: :feature_id

      base.add_check do |entity|
        entity && entities.where(flippable: entity).exists?
      end
    end
  end
end
