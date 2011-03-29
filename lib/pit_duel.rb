
class PitDuel

  def initialize( game, player_x, player_y ) # a duel between x and y
    @player_x = x
    @player_y = y
    @game = game
    @started = false
    @finished = false
    create_pit
  end

  def finished?
    @finished
  end

  def started?
    @started
  end

  def start
    raise "already started" if @started
    @started = true
    if Random.new.rand(1..2) > 1
      CoreCommands::poof @player_x, @nw
      CoreCommands::poof @player_y, @se
    else
      CoreCommands::poof @player_x, @se
      CoreCommands::poof @player_y, @nw
    end
  end

  private
  def create_pit
    @nw = Room.new({ :name => 'NW A Bloody Combat Pit', :description => 'The stone walls of the pit exhibit extensive damage from many glorious battles that have taken place here. Chunks of stone and mortar from the walls are missing or scorched from misguided weapon blows and dodged spells. A rolling fog of blue mist envelopes the loose dirt floor.' })
    @se = Room.new({ :name => 'SE A Bloody Combat Pit', :description => 'The stone walls of the pit exhibit extensive damage from many glorious battles that have taken place here. Chunks of stone and mortar from the walls are missing or scorched from misguided weapon blows and dodged spells. A rolling fog of blue mist envelopes the loose dirt floor.' })
    @ne = Room.new({ :name => 'NE A Bloody Combat Pit', :description => 'The stone walls of the pit exhibit extensive damage from many glorious battles that have taken place here. Chunks of stone and mortar from the walls are missing or scorched from misguided weapon blows and dodged spells. A rolling fog of blue mist envelopes the loose dirt floor.' })
    @sw = Room.new({ :name => 'SW A Bloody Combat Pit', :description => 'The stone walls of the pit exhibit extensive damage from many glorious battles that have taken place here. Chunks of stone and mortar from the walls are missing or scorched from misguided weapon blows and dodged spells. A rolling fog of blue mist envelopes the loose dirt floor.' })
    @nw.exit[Exit::EAST] = Exit.new({room:@nw, destination:@ne, direction:Exit::EAST})
    @sw.exit[Exit::EAST] = Exit.new({room:@sw, destination:@se, direction:Exit::EAST})
    @ne.exit[Exit::WEST] = Exit.new({room:@ne, destination:@nw, direction:Exit::WEST})
    @se.exit[Exit::WEST] = Exit.new({room:@se, destination:@sw, direction:Exit::WEST})
    @ne.exit[Exit::SOUTH] = Exit.new({room:@ne, destination:@se, direction:Exit::SOUTH})
    @nw.exit[Exit::SOUTH] = Exit.new({room:@nw, destination:@sw, direction:Exit::SOUTH})
    @se.exit[Exit::NORTH] = Exit.new({room:@se, destination:@ne, direction:Exit::NORTH})
    @sw.exit[Exit::NORTH] = Exit.new({room:@sw, destination:@nw, direction:Exit::NORTH})
    @rooms = []
    @rooms << @nw << @sw << @se << @ne
  end
end
