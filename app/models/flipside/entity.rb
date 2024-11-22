# frozen_string_literal: true

module Flipside
  # A join table to map entities to an EntityFeature
  class Entity < ::ActiveRecord::Base
    self.table_name = "flipside_entities"

    belongs_to :feature, class_name: "EntityFeature"
    belongs_to :flippable, polymorphic: true
  end
end
