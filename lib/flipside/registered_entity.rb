module Flipside
  class RegisteredEntity
    class Result
      attr_reader :entity, :display_as, :identifier

      def initialize(entity, display_as, identifier)
        @entity = entity
        @display_as = display_as
        @identifier = identifier
      end
    end

    attr_reader :class_name, :search_by, :display_as, :identified_by

    def initialize(class_name:, identified_by: :id, search_by: nil, display_as: nil)
      @class_name = class_name
      @search_by = search_by
      @display_as = display_as
      @identified_by = identified_by
    end

    def search(query)
      Array(lookup_proc.call(query)).map do |entity|
        Result.new(
          entity,
          display(entity),
          entity.public_send(identified_by)
        )
      end
    end

    def find(identifier)
      class_name.constantize.find_by!("#{identified_by}": identifier)
    end

    def display(entity)
      display_proc.call(entity)
    end

    private

    def lookup_proc
      @lookup_proc ||=
        case search_by
        when Proc
          search_by
        when Symbol
          ->(query) { class_name.constantize.where("#{search_by}": query) }
        else
          ->(query) { class_name.constantize.where("#{identified_by}": query) }
        end
    end

    def display_proc
      @display_proc ||=
        case display_as
        when Proc
          display_as
        when Symbol
          ->(entity) { entity.public_send(display_as) }
        else
          ->(entity) { entity.public_send(identified_by) }
        end
    end
  end
end
