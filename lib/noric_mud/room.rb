require_relative 'object'
require_relative 'object_parts/short_name'
require_relative 'object_parts/description'

module NoricMud
  class Room < Object
    include ObjectParts::ShortName
    include ObjectParts::Description
  end
end
