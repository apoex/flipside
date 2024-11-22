# frozen_string_literal: true

module Flipside
  class BaseFeature < ::ActiveRecord::Base
    self.table_name = "flipside_features"

    def enabled?
      return false unless enabled
      return false unless activated?
      return false if deactivated?

      true
    end

    def disabled?
      !enabled?
    end

    # TODO: Time zones?
    def activated?
      return true if activated_at.nil?

      activated_at <= Time.now
    end

    def deactivated?
      return false if deactivated_at.nil?

      deactivated_at <= Time.now
    end
  end
end
