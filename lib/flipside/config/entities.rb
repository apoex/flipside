require "flipside/config/registered_entity"

module Flipside
  module Config
    module Entities
      def register_entity(class_name:, search_by:, display_as:, identified_by: :id)
        deprecator.warn(
          "Flipside.register_entity is deprecated and will be removed in Flipside " \
          "#{deprecator.deprecation_horizon}. Include Flipside::Flippable in " \
          "#{class_name}, call flipside_entity there and list it in Flipside.flippables."
        )
        add_registered_entity(class_name:, search_by:, display_as:, identified_by:)
      end

      def add_registered_entity(class_name:, search_by:, display_as:, identified_by: :id) # :nodoc:
        registered_entities[class_name.to_s] = RegisteredEntity.new(
          class_name:,
          search_by:,
          display_as:,
          identified_by:
        )
      end

      def entity_classes
        load_flippables
        registered_entities.keys
      end

      def search_entity(class_name:, query:)
        load_flippables
        registered_entities.fetch(class_name.to_s).search(query)
      end

      def find_entity(class_name:, identifier:)
        load_flippables
        registered_entities.fetch(class_name.to_s).find(identifier)
      end

      # Accepts either a flippable record or a Flipside::Entity join row. Given
      # a join row, it still renders when the record or its class has been
      # deleted, or the class is no longer registered, so the UI can list it
      # for removal.
      def display_entity(entity)
        return display_flippable(entity) unless entity.is_a?(Flipside::Entity)

        record = entity.flippable if entity.flippable_type.safe_constantize
        label = "#{entity.flippable_type} ##{entity.flippable_id}"

        if record.nil?
          "#{label} (deleted)"
        elsif (registration = registration_for(record.class))
          registration.display(record)
        else
          label
        end
      end

      private

      def display_flippable(record)
        registration = registration_for(record.class)
        raise KeyError, "#{record.class} is not registered with Flipside" unless registration

        registration.display(record)
      end

      # The registration of the class or its closest registered superclass, so
      # an STI subclass is displayed through the base class's registration
      # unless it has one of its own.
      def registration_for(klass)
        klass.ancestors.each do |ancestor|
          next unless ancestor.is_a?(Class)

          registration = registered_entities[ancestor.name]
          return registration if registration
        end
        nil
      end

      def registered_entities
        @registered_entities ||= {}
      end
    end
  end
end
