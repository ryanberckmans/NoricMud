require_relative 'object'
require_relative 'mob'
require_relative 'object_parts/short_name'
require_relative 'object_parts/long_name'
require_relative 'object_parts/description'
require_relative 'object_parts/gender'

module NoricMud
  class MobTemplate < Object
    include ObjectParts::ShortName
    include ObjectParts::LongName
    include ObjectParts::Description
    include ObjectParts::Gender

    # Instantiate a Mob object based on this MobTemplate
    # @return Mob the newly-constructed Mob based on this MobTemplate
    def roll
      mob = Mob.new
      mob.short_name = short_name
      mob.long_name = long_name
      mob.description = description
      mob.gender = gender
      mob
    end
  end
end
