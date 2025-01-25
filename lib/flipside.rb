# frozen_string_literal: true

require "flipside/version"
require "flipside/web"
require "flipside/config/entities"
require "flipside/config/roles"
require "models/flipside/feature"

module Flipside
  extend Config::Entities
  extend Config::Roles

  class Error < StandardError; end

  class NoSuchFeauture < Error
    def initialize(name)
      super("There's no feature named '#{name}'")
    end
  end

  class << self
    def enabled?(name, object = nil)
      feature = find_by(name:)
      return false unless feature

      feature.enabled? object
    end

    def enable!(name)
      feature = find_by!(name:)
      feature.update(enabled: true)
    end

    def add_entity(name:, entity:)
      feature = find_by!(name:)
      Entity.find_or_create_by(feature:, flippable: entity)
    end

    def remove_entity(name:, entity_id:)
      feature = find_by!(name:)
      feature.entities.find_by(id: entity_id)&.destroy
    end

    def add_role(name:, class_name:, method_name:)
      feature = find_by!(name:)
      Role.find_or_create_by(feature:, class_name:, method: method_name)
    end

    def remove_role(name:, role_id:)
      feature = find_by!(name:)
      feature.roles.find_by(id: role_id)&.destroy
    end

    def find_by(name:)
      Feature.find_by(name:)
    end

    def find_by!(name:)
      find_by(name:) || raise(NoSuchFeauture.new(name))
    end
  end
end
