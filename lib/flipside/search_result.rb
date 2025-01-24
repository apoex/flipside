module Flipside
  class SearchResult
    attr_reader :object, :display_as, :identifier

    def initialize(object, display_as, identifier)
      @object = object
      @display_as = display_as
      @identifier = identifier
    end
  end
end
