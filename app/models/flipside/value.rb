# frozen_string_literal: true

module Flipside
  # This class piggybacks on the Role class. They both need the same data, so
  # it feels a bit unnecessary to have two similar db tables.
  class Value < Role
    VALUE_CLASS = "_FlipsideValue_"

    after_initialize { self.class_name = VALUE_CLASS }
    attr_readonly :class_name

    alias_attribute :key, :method
  end
end
