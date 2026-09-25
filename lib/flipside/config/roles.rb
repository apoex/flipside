require "flipside/config/registered_role"

module Flipside
  module Config
    module Roles
      def register_role(class_name:, method_name:, display_as: nil)
        deprecator.warn(
          "Flipside.register_role is deprecated and will be removed in Flipside " \
          "#{deprecator.deprecation_horizon}. Include Flipside::Flippable in " \
          "#{class_name}, call flipside_role there and list it in Flipside.flippables."
        )
        add_registered_role(class_name:, method_name:, display_as:)
      end

      def add_registered_role(class_name:, method_name:, display_as: nil) # :nodoc:
        registered_roles[class_name.to_s] ||= {}
        registered_roles[class_name.to_s][method_name.to_s] = RegisteredRole.new(
          class_name:,
          method_name:,
          display_as:
        )
      end

      def role_classes
        load_flippables
        registered_roles.keys
      end

      def search_role(class_name:, query:)
        load_flippables
        registered_roles.fetch(class_name.to_s).values.filter_map do |registered_role|
          next unless registered_role.match? query
          registered_role.to_result
        end
      end

      private

      def registered_roles
        @registered_roles ||= {}
      end
    end
  end
end
