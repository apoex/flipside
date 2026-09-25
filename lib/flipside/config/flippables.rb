module Flipside
  module Config
    # Names of the classes that register themselves through the
    # Flipside::Flippable macros. Listing them lets Flipside load them on demand,
    # so the UI finds them whether or not the app eager loads.
    module Flippables
      attr_writer :flippables

      def flippables
        @flippables ||= []
      end

      def register_flippable(class_name) # :nodoc:
        registered_flippables << class_name.to_s
      end

      private

      def load_flippables
        flippables.each do |name|
          name.constantize
          next if registered_entities.key?(name) || registered_roles.key?(name)

          raise Error, "#{name} is listed in Flipside.flippables but calls neither " \
            "flipside_entity nor flipside_role"
        end

        unlisted = registered_flippables.to_a - flippables
        return if unlisted.empty?

        raise Error, "#{unlisted.join(", ")} must be listed in Flipside.flippables"
      end

      def registered_flippables
        @registered_flippables ||= Set.new
      end
    end
  end
end
