# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

pit = Room.create({ :name => 'A Bloody Combat Pit', :description => 'The stone walls of the pit exhibit extensive damage from many glorious battles that have taken place here. Chunks of stone and mortar from the walls are missing or scorched from misguided weapon blows and dodged spells. A rolling fog of blue mist envelopes the loose dirt floor.' })

wild = Room.create({ :name => 'A Dense, Forested Wilderness', :description => 'You are in the forest. Surrounding you are the trunks of deciduous trees; high above you their broad leaves filter the sunlight to a trickle by day, and allow only brief glimpses of the moon at night. A cacophony of birdsong and chittering insects fills the air, forming a strangely haunting melody. The smell of vegetation in various stages of decomposition is a pungent reminder of your own mortality. Dry twigs and leaves snap beneath your feet as you walk, and legends of forest demons and spirits fill your thoughts.' })

respawn = Room.create({ :name => 'Within Illuminated Mists', :description => "If you're here, you died!" })

t1 = Room.create({ :name => 'A Darkened Entrance' })
t2 = Room.create({ :name => 'In a Windy Tunnel' })
t3 = Room.create({ :name => 'In a Windy Tunnel' })
t4 = Room.create({ :name => 'A Tight Spot in the Tunnel' })
t5 = Room.create({ :name => 'In a Windy Tunnel' })
t6 = Room.create({ :name => 'In a Windy Tunnel' })
t7 = Room.create({ :name => 'At a Sheer Precipice' })
t8 = Room.create({ :name => 'Entrace to a Subterranean Forest' })

def exit( from, to, dir )
  Exit.create_exit from, to, dir
end

exit respawn, pit, Exit::SOUTH
exit respawn, pit, Exit::WEST
exit respawn, pit, Exit::EAST
exit respawn, pit, Exit::NORTH
exit respawn, pit, Exit::UP
exit respawn, pit, Exit::DOWN

exit pit, wild, Exit::WEST
exit wild, pit, Exit::EAST

exit wild, t1, Exit::DOWN
exit t1, wild, Exit::UP

exit t1, t2, Exit::EAST
exit t2, t1, Exit::WEST

exit t1, t4, Exit::SOUTH
exit t4, t1, Exit::NORTH

exit t4, t3, Exit::EAST
exit t3, t4, Exit::WEST

exit t2, t3, Exit::SOUTH
exit t3, t2, Exit::NORTH

exit t3, t5, Exit::EAST
exit t5, t3, Exit::WEST

exit t5, t6, Exit::EAST
exit t6, t5, Exit::WEST

exit t6, t7, Exit::EAST
exit t7, t6, Exit::WEST

exit t7, t8, Exit::DOWN
exit t8, t7, Exit::UP

exit t8, pit, Exit::DOWN
