require "flipside/config/registered_entity"

module Flipside
  module Config
    module Entities
      def register_entity(class_name:, search_by:, display_as:, identified_by: :id)
        registered_entities[class_name.to_s] = RegisteredEntity.new(
          class_name:,
          search_by:,
          display_as:,
          identified_by:
        )
      end

      def entity_classes
        registered_entities.keys
      end

      def search_entity(class_name:, query:)
        registered_entities.fetch(class_name.to_s).search(query)
      end

      def find_entity(class_name:, identifier:)
        registered_entities.fetch(class_name.to_s).find(identifier)
      end

      def display_entity(entity)
        registered_entities
          .fetch(entity.class.to_s)
          .display(entity)
      end

      private

      def registered_entities
        @registered_entities ||= {}
      end
    end
  end
end
