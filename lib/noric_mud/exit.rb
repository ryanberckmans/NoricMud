require_relative 'object'

module NoricMud
  class Exit < Object
    def destination= room
      set_attribute :destination, room
    end
    def destination
      get_attribute :destination
    end
  end
end
