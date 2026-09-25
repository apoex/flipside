# frozen_string_literal: true

require "active_support/concern"
require "models/flipside/entity"

module Flipside
  # Lets a model register itself with Flipside. The class must also be listed in
  # Flipside.flippables, so that Flipside can load it when the UI needs it. The
  # listing is checked when Flipside loads the classes rather than here, since
  # a model may be loaded before the initializer that sets Flipside.flippables.
  module Flippable
    extend ActiveSupport::Concern

    class_methods do
      # Registers the class as an entity and removes its Flipside::Entity rows
      # when a record is destroyed.
      def flipside_entity(search_by: nil, display_as: nil, identified_by: :id)
        register_flippable!

        has_many :flipside_entities,
          class_name: "Flipside::Entity",
          as: :flippable,
          dependent: :delete_all

        Flipside.add_registered_entity(class_name: name, search_by:, display_as:, identified_by:)
      end

      def flipside_role(method_name, display_as: nil)
        register_flippable!

        Flipside.add_registered_role(class_name: name, method_name:, display_as:)
      end

      private

      def register_flippable!
        raise Flipside::Error, "Flipside macros need a named class" if name.nil?

        Flipside.register_flippable(name)
      end
    end
  end
end
