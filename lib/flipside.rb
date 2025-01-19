# frozen_string_literal: true

require "flipside/version"
require "flipside/web"
require "models/flipside/feature"

module Flipside
  # Add class methods flipside_enity and flipside_role to models
  #
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
      Entity.create(feature:, flippable: entity)
    end

    def add_role(name:, class_name:, method:)
      feature = find_by!(name:)
      Role.create(feature:, class_name:, method:)
    end

    def add_key(name:, key:)
      feature = find_by!(name:)
      Key.create(feature:, key: key)
    end

    def find_by(name:)
      Feature.find_by(name:)
    end

    def find_by!(name:)
      find_by(name:) || raise(NoSuchFeauture.new(name))
    end
  end
end
