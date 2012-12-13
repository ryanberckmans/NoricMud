require_relative 'object'
require_relative 'room'
require_relative 'object_parts/short_name'
require_relative 'object_parts/description'

module NoricMud
  class RoomTemplate < Object
    include ObjectParts::ShortName
    include ObjectParts::Description

    def initialize params={}
      super params
      set_attribute_unless_exists :room_instance_ids, []
    end

    # Add a new room_instance_id to this RoomTemplate, denoting a usage of this room in a containing ZoneTemplate
    # @param room_instance_id - the room_instance_id to add
    # @return nil
    def add_room_instance_id room_instance_id
      raise "#{room_instance_id} is already a room_instance_id and must be unique" if get_attribute(:room_instance_ids).include? room_instance_id
      get_attribute(:room_instance_ids) << room_instance_id
      nil
    end

    # Delete a room_instance_id from this RoomTemplate
    # @param room_instance_id - the room_instance_id to delete
    # @return nil
    def delete_room_instance_id room_instance_id
      get_attribute(:room_instance_ids).delete room_instance_id
      nil
    end

    # Clear all room_instance_ids from this RoomTemplate
    # @return nil
    def clear_room_instance_ids
      get_attribute(:room_instance_ids).clear
      nil
    end

    # Return an Enumerator of all room_instance_ids for this RoomTemplate
    # Each room_instance_id corresponds to a usage of this RoomTemplate in a containing ZoneTemplate
    # @return Enumerator |room_instance_id|
    def each_room_instance_id
      get_attribute(:room_instance_ids).each
    end
    
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
