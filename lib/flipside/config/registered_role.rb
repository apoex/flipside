require "flipside/search_result"

module Flipside
  class RegisteredRole
    attr_reader :class_name, :method_name, :display_as

    def initialize(class_name:, method_name:, display_as: nil)
      @class_name = class_name
      @method_name = method_name
      @display_as = display_as || method_name.to_s
    end

    def to_result
      SearchResult.new(
        nil,
        display,
        method_name
      )
    end

    def match?(query)
      query = query.to_s.downcase
      method_name.to_s.downcase.include?(query) ||
        display.to_s.downcase.include?(query)
    end

    def display
      display_proc.call
    end

    private

    def display_proc
      @display_proc ||=
        case display_as
        when Proc
          display_as
        else
          -> { display_as }
        end
    end
  end
end
