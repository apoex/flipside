# frozen_string_literal: true

module Flipside
  module Checks
    def add_check(&block)
      checks << block
    end

    def checks
      @checks ||= []
    end
  end
end
