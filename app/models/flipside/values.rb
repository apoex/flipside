# frozen_string_literal: true

require "models/flipside/value"

module Flipside
  module Values
    VALUE_KEY = "FlipsideValue"

    def self.included(base)
      validate_roles! base
      base.add_check { |value| enabled_for? value.to_s }
    end

    def self.validate_roles!(base)
      return if base.ancestors.include? Roles
      raise "Internal error in Flipside: Roles module has not been loaded"
    end

    def enabled_for?(value)
      return false if value.blank?

      roles.where(
        class_name: Value::VALUE_CLASS,
        method: value
      ).exists?
    end
  end
end
