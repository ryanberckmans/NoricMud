
class PitDuel

  def initialize( game, mob_x, mob_y ) # a duel between x and y
    @mob_x_orig_location = nil
    @mob_y_orig_location = nil
    @mob_x = mob_x
    @mob_y = mob_y
    @game = game
    @started = false
    @finished = false
    @winner = nil
    @loser = nil
    create_pit
    Log::debug "initialized #{@mob_x.short_name} vs #{@mob_y.short_name}", "pitduel"
  end

  def finished?
    @finished
  end

  def started?
    @started
  end

  def winner
    @winner
  end

  def loser
    @loser
  end

  def start
    Log::info "starting #{@mob_x.short_name} vs #{@mob_y.short_name}", "pitduel"
    raise "already started" if @started
    PhysicalState::transition @game, @mob_x, PhysicalState::Standing if @mob_x.dead?
    PhysicalState::transition @game, @mob_y, PhysicalState::Standing if @mob_y.dead?
    @started = true
    teleport_combatants
    Combat::restore @mob_x
    Combat::restore @mob_y
    @game.signal.connect PhysicalState::Dead::SIGNAL, ->mob{ loss mob; true }, @mob_x
    @game.signal.connect PhysicalState::Dead::SIGNAL, ->mob{ loss mob; true }, @mob_y
  end

  private
  def loss( mob )
    raise "raised mob to be @mob_x or @mob_y" unless mob == @mob_x or mob == @mob_y
    @loser = mob
    if mob == @mob_x
      @winner = @mob_y
    elsif mob == @mob_y
      @winner = @mob_x
    else
      raise "expected mob to be mob_x or mob_y"
    end
    Log::debug "mob #{@winner.short_name} won vs #{@loser.short_name}, pit duel #{self.to_s}", "pitduel"
    @finished = true
    return_combatants
  end

  def return_combatants
    Log::debug "returning #{@mob_x.short_name} and #{@mob_y.short_name} to previous location", "pitduel"
    CoreCommands::poof @game, @mob_x, @mob_x_orig_location
    CoreCommands::poof @game, @mob_y, @mob_y_orig_location
  end
  
  def teleport_combatants
    Log::debug "teleporting #{@mob_x.short_name} and #{@mob_y.short_name} to pit", "pitduel"
    @mob_x_orig_location = @mob_x.room
    @mob_y_orig_location = @mob_y.room
    if Random.new.rand(1..2) > 1
      CoreCommands::poof @game, @mob_x, @nw
      CoreCommands::poof @game, @mob_y, @se
    else
      CoreCommands::poof @game, @mob_x, @se
      CoreCommands::poof @game, @mob_y, @nw
    end
  end
  
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
