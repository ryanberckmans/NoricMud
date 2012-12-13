require_relative 'object'
require_relative 'zone'
require_relative 'room_template'
require_relative 'object_parts/short_name'
require_relative 'object_parts/description'

module NoricMud
  class ZoneTemplate < Object
    include ObjectParts::ShortName
    include ObjectParts::Description

    def initialize params={}
      super params
      set_attribute_unless_exists :rooms, {}
      set_attribute_unless_exists :next_room_instance_id, 0
    end

    # Add a new room to this zone, backed by the passed RoomTemplate
    # The new room will be assigned a room_instance_id
    # @param room_template - the RoomTemplate backing the new room
    # @return room_instance_id of new room
    def add_room room_template
      raise "only a room_template may be added to a zone" unless room_template.is_a? RoomTemplate
      NoricMud::move room_template, self
      room_instance_id = next_room_instance_id
      get_attribute(:rooms)[room_instance_id] = room_template
      room_instance_id
    end

    # Delete the existing room with the passed room_instance_id from this zone
    # @param room_instance_id - the id of the room to delete
    def delete_room room_instance_id
      raise "pending"
    end

    # Return an Enumerator containing each room in this zone.
    # @return Enumerator |room_instance_id,room_template| containing the rooms in this ZoneTemplate
    def each_room
      get_attribute(:rooms).each_pair
    end

    # Instantiate a Zone object based on this ZoneTemplate
    # @return Zone the newly-constructed Zone based on this ZoneTemplate
    def roll
      zone = Zone.new
      zone.short_name = short_name
      zone.description = description
      zone
    end

    protected
    def next_room_instance_id
      next_room_instance_id = get_attribute :next_room_instance_id
      set_attribute :next_room_instance_id, (next_room_instance_id+1)
      next_room_instance_id
    end
  end
end
