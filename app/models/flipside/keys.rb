# frozen_string_literal: true

require "models/flipside/key"

module Flipside
  module Keys
    def self.included(base)
      validate_roles! base
      base.add_check { |key| enabled_for? key.to_s }
    end

    def self.validate_roles!(base)
      return if base.ancestors.include? Roles
      raise "Internal error in Flipside: Roles module has not been loaded"
    end

    def enabled_for?(key)
      return false if key.blank?

      roles.where(
        class_name: Key::KEY_CLASS,
        method: key
      ).exists?
    end
  end
end
