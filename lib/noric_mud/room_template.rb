require_relative 'object'
require_relative 'room'
require_relative 'object_parts/short_name'
require_relative 'object_parts/description'

module NoricMud
  class RoomTemplate < Object
    include ObjectParts::ShortName
    include ObjectParts::Description

    # Instantiate a Room object based on this RoomTemplate
    # @return Room the newly-constructed Room based on this RoomTemplate
    def roll
      room = Room.new
      room.short_name = short_name
      room.description = description
      room
    end
  end
end
