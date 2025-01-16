# frozen_string_literal: true

require "models/flipside/role"

module Flipside
  module Roles
    def self.included(base)
      base.has_many :roles, foreign_key: :feature_id
      base.add_check { |object| has_role? object }
    end

    def has_role?(object)
      methods = lookup_methods_for(object)
      methods.any? { |method| object.public_send(method) }
    end

    def lookup_methods_for(object)
      roles
        .where(class_name: object.class.to_s)
        .pluck(:method)
        .select { |method| object.respond_to?(method) }
    end
  end
end
