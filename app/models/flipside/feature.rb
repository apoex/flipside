# frozen_string_literal: true

require "models/flipside/checks"
require "models/flipside/entities"
require "models/flipside/roles"
require "models/flipside/values"

module Flipside
  class Feature < ::ActiveRecord::Base
    extend Checks
    include Entities
    include Roles
    include Values

    self.table_name = "flipside_features"

    def enabled?(object = nil)
      return false unless active?
      return true if enabled

      self.class.checks.any? { |check| instance_exec(object, &check) }
    end

    def active?
      activated? && !deactivated?
    end

    private

    def activated?
      return true if activated_at.nil?

      activated_at <= Time.current
    end

    def deactivated?
      return false if deactivated_at.nil?

      deactivated_at <= Time.current
    end
  end
end
