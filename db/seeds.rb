require "mud"

acc = Account.create({name:"spiritic", password:"pw"})
noric = Character.new({name:"Noric"})
noric.account = acc
noric.mob = Mob.new({:short_name => noric.name, :long_name => "{FGLegionnaire {FY#{noric.name}{FG the legendary hero"})
noric.save
spiritic = Character.new({name:"Spiritic"})
spiritic.account = acc
spiritic.mob = Mob.new({:short_name => spiritic.name, :long_name => "{FGLegionnaire {FY#{spiritic.name}{FG the legendary hero"})
spiritic.save

def room( name, desc="" )
  Room.create({name:name, description:desc})
end

def exit( from, to, dir )
  Exit.create_exit from, to, dir
end

def bi_exit( from, to, dir )
  exit from, to, dir
  exit to, from, Exit.reverse(dir)
end

def safe( room )
  room.safe = true
  raise "save failed" unless room.save
end

def quit( room )
  room.quit = true
  raise "save failed" unless room.save
end


############################################
# Login area

treehouse = room "An Alpine Canopy Dwelling", "Several hundred feet above the ground, silk hammocks dot the massive redwoods where the ancient trunks give way to a lazy canopy. A rope ladder, swaying in the high-altitude winds, winds its way down to the distant floor. The dwelling is framed by snow-capped peaks dominating the horizon in all directions."
safe treehouse
quit treehouse

l1 = room "Within a Grove of Massive Redwoods", "Dozens of ancient, commanding, redwood trees have starved the forest floor of other vegetation. The resulting grove, empty save the towering boles, possess conflicting attributes of emptiness and incubation. A rope ladder, anchored to a redwood, sways upward into the distant, hazy, canopy."
safe l1

l2 = room "A Clearing Before the Mountain", ""
safe l2

l3 = room "The Edge of an Ancient Glacier", ""
safe l3

l4 = room "Within a Grove of Massive Redwoods", ""
safe l4

l5 = room "A Forgotten Shrine", ""
safe l5

bi_exit treehouse, l1, Exit::DOWN
bi_exit l1, l2, Exit::EAST
bi_exit l2, l3, Exit::SOUTH
bi_exit l3, l4, Exit::WEST
bi_exit l1, l4, Exit::SOUTH
bi_exit l4, l5, Exit::SOUTH

############################################
# Dueling area

staging = room "Entrance to the Arena"
safe staging
bi_exit staging, l3, Exit::UP

pit_nw = Room.create({ :name => 'A Bloody Combat Pit', :description => 'The stone walls of the pit exhibit extensive damage from many glorious battles that have taken place here. Chunks of stone and mortar from the walls are missing or scorched from misguided weapon blows and dodged spells. A rolling fog of blue mist envelopes the loose dirt floor.' })

pit_se = Room.create({ :name => 'A Bloody Combat Pit', :description => 'The stone walls of the pit exhibit extensive damage from many glorious battles that have taken place here. Chunks of stone and mortar from the walls are missing or scorched from misguided weapon blows and dodged spells. A rolling fog of blue mist envelopes the loose dirt floor.' })

pit_ne = Room.create({ :name => 'A Bloody Combat Pit', :description => 'The stone walls of the pit exhibit extensive damage from many glorious battles that have taken place here. Chunks of stone and mortar from the walls are missing or scorched from misguided weapon blows and dodged spells. A rolling fog of blue mist envelopes the loose dirt floor.' })

pit_sw = Room.create({ :name => 'A Bloody Combat Pit', :description => 'The stone walls of the pit exhibit extensive damage from many glorious battles that have taken place here. Chunks of stone and mortar from the walls are missing or scorched from misguided weapon blows and dodged spells. A rolling fog of blue mist envelopes the loose dirt floor.' })

bi_exit pit_sw, pit_nw, Exit::NORTH
bi_exit pit_nw, pit_ne, Exit::EAST
bi_exit pit_ne, pit_se, Exit::SOUTH
bi_exit pit_se, pit_sw, Exit::WEST
bi_exit pit_sw, staging, Exit::UP

# wild = Room.create({ :name => 'A Dense, Forested Wilderness', :description => 'You are in the forest. Surrounding you are the trunks of deciduous trees; high above you their broad leaves filter the sunlight to a trickle by day, and allow only brief glimpses of the moon at night. A cacophony of birdsong and chittering insects fills the air, forming a strangely haunting melody. The smell of vegetation in various stages of decomposition is a pungent reminder of your own mortality. Dry twigs and leaves snap beneath your feet as you walk, and legends of forest demons and spirits fill your thoughts.' })

############################################
# Respawn area

respawn = Room.create({ :name => 'Within Illuminated Mists', :description => "If you're here, you died!" })
safe respawn
quit respawn

exit respawn, l5, Exit::SOUTH
exit respawn, l5, Exit::WEST
exit respawn, l5, Exit::EAST
exit respawn, l5, Exit::NORTH
exit respawn, l5, Exit::UP
exit respawn, l5, Exit::DOWN

############################################
# FFA area


t8 = Room.create({ :name => 'Entrance to a Subterranean Forest' })
bi_exit l2, t8, Exit::EAST
