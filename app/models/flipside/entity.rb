# frozen_string_literal: true

module Flipside
  # A join table to map entities to a Feature
  class Entity < ::ActiveRecord::Base
    self.table_name = "flipside_entities"

    belongs_to :feature
    belongs_to :flippable, polymorphic: true
  end
end
