require_relative 'object'
require_relative 'object_parts/short_name'
require_relative 'object_parts/long_name'
require_relative 'object_parts/description'
require_relative 'object_parts/gender'

module NoricMud
  class Mob < Object
    include ObjectParts::ShortName
    include ObjectParts::LongName
    include ObjectParts::Description
    include ObjectParts::Gender
  end
end
