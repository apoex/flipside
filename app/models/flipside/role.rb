# frozen_string_literal: true

module Flipside
  # A join table to map roles to a Feature
  class Role < ::ActiveRecord::Base
    self.table_name = "flipside_roles"

    belongs_to :feature
  end
end
