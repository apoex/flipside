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
      class_attribute :_flipside_search_by, :_flipside_display_as, :_flipside_identified_by,
        instance_accessor: false, instance_predicate: false
    end

    class_methods do
      # Registers the class as an entity and removes its Flipside::Entity rows
      # when a record is destroyed. Calling flipside_search_by,
      # flipside_display_as or flipside_identified_by does the same, so this is
      # only needed to register with the defaults.
      def flipside_entity(search_by: nil, display_as: nil, identified_by: nil)
        register_flipside_entity!
        deprecated_entity_options(search_by:, display_as:, identified_by:)
      end

      # Sets the column that identifies an entity, :id by default. Registers the
      # class as an entity, as flipside_entity does.
      def flipside_identified_by(column)
        self._flipside_identified_by = column.to_sym
        register_flipside_entity!
      end

      # Sets how entities are found from a search in the UI, either with a block
      # run in the context of the class or the name of a class method (e.g. a
      # scope). Either is given the search string and returns the matching
      # records. Registers the class as an entity, as flipside_entity does.
      def flipside_search_by(method_name = nil, &block)
        self._flipside_search_by = method_or_block(method_name, block)
        register_flipside_entity!
      end

      # Sets how entities are displayed in the UI, either with a block given the
      # record or the name of an instance method. Either returns a string.
      # Registers the class as an entity, as flipside_entity does.
      def flipside_display_as(method_name = nil, &block)
        self._flipside_display_as = method_or_block(method_name, block)
        register_flipside_entity!
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

      # Safe to call more than once. The registration is replaced each time, so
      # that it picks up identified_by whichever order the macros are called in.
      def register_flipside_entity!
        register_flippable!

        unless @flipside_entity_registered
          has_many :flipside_entities,
            class_name: "Flipside::Entity",
            as: :flippable,
            dependent: :delete_all
          @flipside_entity_registered = true
        end

        Flipside.add_registered_entity(
          class_name: name,
          search_by: ->(query) { flipside_search(query) },
          display_as: ->(entity) { flipside_display(entity) },
          identified_by: flipside_identifier_column
        )
      end

      def flipside_identifier_column
        _flipside_identified_by || :id
      end

      def method_or_block(method_name, block)
        return method_name.to_sym if method_name && !block
        return block if block && !method_name

        raise ArgumentError, "pass either a method name or a block"
      end

      def flipside_search(query)
        case _flipside_search_by
        when Symbol then public_send(_flipside_search_by, query)
        when Proc then instance_exec(query, &_flipside_search_by)
        else where(flipside_identifier_column => query)
        end
      end

      def flipside_display(entity)
        case _flipside_display_as
        when Symbol then entity.public_send(_flipside_display_as)
        when Proc then _flipside_display_as.call(entity)
        else entity.public_send(flipside_identifier_column)
        end
      end

      def deprecated_entity_options(search_by:, display_as:, identified_by:)
        return if search_by.nil? && display_as.nil? && identified_by.nil?

        Flipside.deprecator.warn(
          "The search_by, display_as and identified_by options of flipside_entity are " \
          "deprecated and will be removed in Flipside #{Flipside.deprecator.deprecation_horizon}. " \
          "Use flipside_search_by, flipside_display_as and flipside_identified_by in " \
          "#{name} instead. Note that " \
          "a method name given to flipside_search_by names a class method or scope, so " \
          "search_by: :name becomes flipside_search_by { |query| where(name: query) }."
        )

        flipside_identified_by(identified_by) if identified_by

        case search_by
        when Symbol then flipside_search_by { |query| where(search_by => query) }
        when Proc then flipside_search_by(&search_by)
        end

        case display_as
        when Symbol then flipside_display_as(display_as)
        when Proc then flipside_display_as(&display_as)
        when String then flipside_display_as { display_as }
        end
      end
    end
  end
end
