files = Dir.glob Util.here "*.rb"
files.each do |f| require f end

module Abilities
  @commands = AbbrevMap.new
  ABILITIES_HANDLER_PRIORITY = 15
  
  def self.add_cmd( cmd, callback )
    @commands.add cmd, callback
  end

  def self.commands
    @commands
  end

  def self.attempt_energy_use( game, mob, energy )
    if mob.energy < energy
      game.send_msg mob, "{@You can't summon enough energy.\n"
      false
    else
      mob.energy -= energy
      game.send_msg mob, "{!{FWYou invoke the magic and are drained of #{energy} energy.\n"
      true
    end
  end

  def self.use_ability( game, attacker, target, ability, energy_cost, cooldown, lag, channel )
    raise "expected attacker to be a Mob" unless attacker.kind_of? Mob
    raise "expected target to be a String" unless target.kind_of? String
    if game.in_cooldown? attacker, ability
      game.send_msg attacker, "{@That ability is currently cooling down!\n"
      return nil
    end

    if channel > 0
      game.channel attacker, ->{ use_ability game, attacker, target, ability, energy_cost, cooldown, lag, 0 }, channel
      return nil
    end
    
    target_mob = nil
    if target.empty? and game.combat.engaged? attacker
      target_mob = game.combat.target_of attacker
    elsif target.empty?
      game.send_msg attacker, "{@Upon who?\n"
      return nil
    else
      attacker.room.mobs.each do |mob_in_room|
        if mob_in_room.short_name =~ Regexp.new( "^#{target}", Regexp::IGNORECASE) and attacker != mob_in_room
          target_mob = mob_in_room
          break
        end
      end
    end

    return nil unless attempt_energy_use game, attacker, energy_cost

    if target_mob
      ability.call game, attacker, target_mob
    else
      game.send_msg attacker, "Nobody here by that name.\n"
    end
    game.add_cooldown attacker, ability, cooldown
    game.add_lag attacker, lag
    true
  end
  
  add_cmd "cast nuke", ->(game, mob, rest, match) { use_ability( game, mob, rest, NUKE, NUKE_COST, NUKE_COOLDOWN, NUKE_LAG, NUKE_CHANNEL) }
end
