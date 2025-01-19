# frozen_string_literal: true

module Flipside
  # This class piggybacks on the Role class. They both need the same data, so
  # it feels a bit unnecessary to have two similar db tables.
  class Key < Role
    KEY_CLASS = "_FlipsideKey_"

    after_initialize { self.class_name = KEY_CLASS }
    attr_readonly :class_name

    alias_attribute :key, :method
  end
end
