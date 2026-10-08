# frozen_string_literal: true

require "active_support/concern"
require "active_support/core_ext/class/attribute"
require "models/flipside/entity"

module Flipside
  # Lets a model register itself with Flipside. The class must also be listed in
  # Flipside.flippables, so that Flipside can load it when the UI needs it. The
  # listing is checked when Flipside loads the classes rather than here, since
  # a model may be loaded before the initializer that sets Flipside.flippables.
  module Flippable
    extend ActiveSupport::Concern

    included do
      # The class's Flipside::RegisteredEntity. Being a class attribute, it is
      # inherited by STI subclasses and starts out empty in a reloaded class.
      class_attribute :_flipside_registration, instance_accessor: false, instance_predicate: false
    end

    class_methods do
      # Registers the class as an entity and removes its Flipside::Entity rows
      # when a record is destroyed. Calling flipside_search_by,
      # flipside_display_as or flipside_identified_by does the same, so this is
      # only needed to register with the defaults.
      def flipside_entity(search_by: nil, display_as: nil, identified_by: nil)
        flipside_registration
        deprecated_entity_options(search_by:, display_as:, identified_by:)
      end

      # Sets how entities are found from a search in the UI, either with a block
      # or the name of a column. The block is run in the context of the class,
      # given the search string, and returns the matching records. A column
      # matches the search string exactly. Registers the class as an entity, as
      # flipside_entity does.
      def flipside_search_by(column = nil, &block)
        flipside_registration.search_by = name_or_block(column, block)
      end

      # Sets how entities are displayed in the UI, either with a block given the
      # record or the name of an instance method. Either returns a string.
      # Registers the class as an entity, as flipside_entity does.
      def flipside_display_as(method_name = nil, &block)
        flipside_registration.display_as = name_or_block(method_name, block)
      end

      # Sets the column that identifies an entity, :id by default. Registers the
      # class as an entity, as flipside_entity does.
      def flipside_identified_by(column)
        flipside_registration.identified_by = column.to_sym
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

      # The registration this class owns, created on first use. An STI subclass
      # starts from a copy of the settings it inherits.
      def flipside_registration
        return _flipside_registration if _flipside_registration&.class_name == name

        register_flippable!

        has_many :flipside_entities,
          class_name: "Flipside::Entity",
          as: :flippable,
          dependent: :delete_all

        self._flipside_registration = Flipside.add_registered_entity(
          class_name: name,
          **(_flipside_registration&.options || {})
        )
      end

      def name_or_block(name, block)
        return name.to_sym if name && !block
        return block if block && !name

        raise ArgumentError, "pass either a name or a block"
      end

      def deprecated_entity_options(search_by:, display_as:, identified_by:)
        return if search_by.nil? && display_as.nil? && identified_by.nil?

        Flipside.deprecator.warn(
          "The search_by, display_as and identified_by options of flipside_entity are " \
          "deprecated and will be removed in Flipside #{Flipside.deprecator.deprecation_horizon}. " \
          "Use flipside_search_by, flipside_display_as and flipside_identified_by in " \
          "#{name} instead."
        )

        registration = flipside_registration
        registration.search_by = search_by if search_by
        registration.display_as = display_as if display_as
        registration.identified_by = identified_by if identified_by
      end
    end
  end
end
