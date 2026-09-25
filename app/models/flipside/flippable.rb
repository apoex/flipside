# frozen_string_literal: true

require "active_support/concern"
require "models/flipside/entity"

module Flipside
  # Include in models used as entities, to remove their Flipside::Entity rows
  # when a record is destroyed.
  module Flippable
    extend ActiveSupport::Concern

    included do
      has_many :flipside_entities,
        class_name: "Flipside::Entity",
        as: :flippable,
        dependent: :delete_all
    end
  end
end
