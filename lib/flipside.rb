# frozen_string_literal: true

require "flipside/version"
require "flipside/web"
require "models/flipside/feature"

module Flipside
  # Add class methods flipside_enity and flipside_role to models
  #
  class Error < StandardError; end
  # Your code goes here...

  def self.enabled?(name, object = nil)
    feature = Feature.find_by(name:)
    return false unless feature

    feature.enabled? object
  end
end
