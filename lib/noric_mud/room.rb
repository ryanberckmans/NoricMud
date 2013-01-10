require_relative 'object'
require_relative 'object_parts/short_name'
require_relative 'object_parts/description'

module NoricMud
  class Room < Object
    include ObjectParts::ShortName
    include ObjectParts::Description

    # Look appearance is used when looking in this room
    def long_appearance
      look = "{!{FY#{short_name}\n"
      look += "{FM#{description}\n" unless not description or description.empty?
      contents.each do |object_in_room|
        look += object_in_room.short_appearance
      end
      look
    end
  end
end
