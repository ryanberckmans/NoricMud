# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

pit = Room.create({ :name => 'A Bloody Combat Pit', :description => 'The stone walls of the pit exhibit extensive damage from many glorious battles that have taken place here. Chunks of stone and mortar from the walls are missing or scorched from misguided weapon blows and dodged spells. A rolling fog of blue mist envelopes the loose dirt floor.' })

wild = Room.create({ :name => 'A Dense, Forested Wilderness', :description => 'You are in the forest. Surrounding you are the trunks of deciduous trees; high above you their broad leaves filter the sunlight to a trickle by day, and allow only brief glimpses of the moon at night. A cacophony of birdsong and chittering insects fills the air, forming a strangely haunting melody. The smell of vegetation in various stages of decomposition is a pungent reminder of your own mortality. Dry twigs and leaves snap beneath your feet as you walk, and legends of forest demons and spirits fill your thoughts.' })

Exit.create({ :room => pit, :direction => Exit::WEST, :destination => wild })

Exit.create({ :room => wild, :direction => Exit::EAST, :destination => pit })
