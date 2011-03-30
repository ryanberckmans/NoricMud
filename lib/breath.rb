
BREATH_COST = {
  # a subsequent move that occurs x pulses after a move will cost y breath, for x => y
  0 => 25,
  1 => 25,
  2 => 20,
  3 => 15,
  4 => 10,
  5 => 5,
}

class Breath
  BR_REGEN_INTERVAL = 4
  BR_MAX = 100
  VERY_LOW_BR = 10
  LOW_BR = 40
  BR_REGEN = 9
  COLLAPSE_DISTANCE = 2
  FAIL_MOVE_BREATH = -10 # allow people to use slightly more breath than they have
  
  def initialize( game )
    @game = game
    @regen_timer = BR_REGEN_INTERVAL
    @time = 0
    @last_breath = {}
    @breath = {}
  end

  def tick
    Log::debug "start tick", "breath"
    @time += 1
    @regen_timer -= 1
    if @regen_timer < 1
      Log::debug "regen br", "breath"
      @regen_timer = BR_REGEN_INTERVAL
      @breath.each_key do |mob|
        @breath[mob] += BR_REGEN
        @breath[mob] = BR_MAX if @breath[mob] > BR_MAX
        low_breath mob if @breath[mob] < LOW_BR
        Log::debug "#{mob.short_name} had #{@breath[mob]}br", "breath"
      end
    end
    Log::debug "end tick", "breath"
  end

  def breath( mob )
    default_breath mob
    @breath[mob]
  end

  def try_move( mob )
    # try a move, consuming breath rate, and return true if the move was successful
    default_breath mob
    distance = @time - @last_breath[mob]
    breath_cost = 0
    breath_cost = BREATH_COST[distance] if BREATH_COST.key? distance
    @last_breath[mob] = @time
    if @breath[mob] - breath_cost < FAIL_MOVE_BREATH
      if distance < COLLAPSE_DISTANCE
        # movement too close together, collapse
        fail_move_with_collapse mob
      else
        fail_move mob
      end
      move_successful = false
    else
      @breath[mob] -= breath_cost
      @breath[mob] = 0 if @breath[mob] < 0
      very_low_breath mob if @breath[mob] < VERY_LOW_BR
      move_successful = true
    end
    Log::debug "mob #{mob.short_name}, move succ? #{move_successful}, distance since last move #{distance}, breath cost #{breath_cost}, final br #{@breath[mob]}", "breath"
    move_successful
  end

  def breath_color( mob )
    br = breath mob
    quartile = br * 1.0 / BR_MAX
    quartile_color(quartile) + br.to_s
  end

  private
  def fail_move_with_collapse( mob )
    pov_scope do
      pov(mob) { "{!{FGYou collapse, totally out of breath!\n" }
      pov(mob.room.mobs) { "{!{FG#{mob.short_name} collapses, totally out of breath!\n" }
    end
    PhysicalState::transition @game, mob, PhysicalState::Resting
    @game.add_lag mob, Combat::COMBAT_ROUND * 2 / 3
  end

  def fail_move( mob )
    pov_scope do 
      pov(mob) { "{!{FGYou stop and pant loudly, sucking in air!\n" }
      pov(mob.room.mobs) { "{!{FG#{mob.short_name} stops and pants loudly, sucking in air!\n" }
    end
  end
  
  def low_breath( mob )
    pov_scope do
      pov(mob) { "{!{FGYou pant loudly, breathing hard.\n" }
      pov(mob.room.mobs) { "{!{FG#{mob.short_name} pants loudly, breathing hard.\n" }
    end
  end

  def very_low_breath( mob )
    pov_scope do 
      pov(mob) { "{!{FGYou pant loudly, almost out of breath.\n" }
      pov(mob.room.mobs) { "{!{FG#{mob.short_name} pants loudly, almost out of breath.\n" }
    end
  end
  
  def default_breath( mob )
    raise unless mob.kind_of? Mob
    @last_breath[mob] ||= @time
    @breath[mob] ||= BR_MAX
  end

  def quartile_color( quartile)
    if quartile < 0.25
      "{FR"
    elsif quartile < 0.5
      "{FY"
    elsif quartile < 0.75
      "{FG"
    else
      "{FU"
    end
  end
  
end
