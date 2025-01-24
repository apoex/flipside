require "flipside/config/registered_role"

module Flipside
  module Config
    module Roles
      def register_role(class_name:, method_name:, display_as: nil)
        registered_roles[class_name.to_s] ||= []
        registered_roles[class_name.to_s] << RegisteredRole.new(
          class_name:,
          method_name:,
          display_as:
        )
      end

      def role_classes
        registered_roles.keys
      end

      def search_role(class_name:, query:)
        registered_roles.fetch(class_name.to_s).filter_map do |registered_role|
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
