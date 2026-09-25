# frozen_string_literal: true

require "active_support/concern"
require "models/flipside/entity"

module Flipside
  # Lets a model register itself with Flipside. The class must also be listed in
  # Flipside.flippables, so that Flipside can load it when the UI needs it.
  module Flippable
    extend ActiveSupport::Concern

    class_methods do
      # Registers the class as an entity and removes its Flipside::Entity rows
      # when a record is destroyed.
      def flipside_entity(search_by: nil, display_as: nil, identified_by: :id)
        ensure_listed_in_flippables!

        has_many :flipside_entities,
          class_name: "Flipside::Entity",
          as: :flippable,
          dependent: :delete_all

        Flipside.register_entity(class_name: name, search_by:, display_as:, identified_by:)
      end

      def flipside_role(method_name, display_as: nil)
        ensure_listed_in_flippables!

        Flipside.register_role(class_name: name, method_name:, display_as:)
      end

      private

      def ensure_listed_in_flippables!
        raise Flipside::Error, "Flipside macros need a named class" if name.nil?
        return if Flipside.flippables.include?(name)

        raise Flipside::Error, "#{name} must be listed in Flipside.flippables"
      end
    end
  end
end
