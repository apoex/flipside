require "flipside/search_result"

module Flipside
  class RegisteredEntity
    attr_reader :class_name
    attr_accessor :search_by, :display_as, :identified_by

    # Turns a column name, which search_by matched exactly in the deprecated
    # register_entity and flipside_entity options, into a search block.
    def self.column_search(search_by)
      return search_by unless search_by.is_a?(Symbol)

      ->(query) { where(search_by => query) }
    end

    def initialize(class_name:, identified_by: :id, search_by: nil, display_as: nil)
      @class_name = class_name
      @search_by = search_by
      @display_as = display_as
      @identified_by = identified_by
    end

    def options
      {search_by:, display_as:, identified_by:}
    end

    def search(query)
      Array(lookup(query)).map do |entity|
        SearchResult.new(
          entity,
          display(entity),
          entity.public_send(identified_by)
        )
      end
    end

    def find(identifier)
      klass.find_by!("#{identified_by}": identifier)
    end

    def display(entity)
      case display_as
      when Proc then display_as.call(entity)
      when Symbol then entity.public_send(display_as)
      when String then display_as
      else entity.public_send(identified_by)
      end
    end

    private

    # A block runs in the context of the class and a Symbol names a class
    # method (e.g. a scope), so both can call where directly.
    def lookup(query)
      case search_by
      when Proc then klass.instance_exec(query, &search_by)
      when Symbol then klass.public_send(search_by, query)
      else klass.where("#{identified_by}": query)
      end
    end

    def klass
      class_name.constantize
    end
  end
end
