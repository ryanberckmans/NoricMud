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

  def self.use_ability( game, attacker, target, ability, energy_cost )
    raise "expected attacker to be a Mob" unless attacker.kind_of? Mob
    raise "expected target to be a String" unless target.kind_of? String
    target_mob = nil
    if target.empty? and game.combat.engaged? attacker
      target_mob = game.combat.target_of attacker
    elsif target.empty?
      game.send_msg attacker, "Upon who?\n"
      return nil
    else
      attacker.room.mobs.each do |mob_in_room|
        if mob_in_room.short_name =~ Regexp.new( "^#{target}", Regexp::IGNORECASE) and attacker != mob_in_room
          target_mob = mob_in_room
          break
        end
      end
    end

    return unless attempt_energy_use game, attacker, energy_cost

    if target_mob
      ability.call target_mob
    else
      game.send_msg attacker, "Nobody here by that name.\n"
    end
    true
  end
  
  add_cmd "cast nuke", ->(game, mob, rest, match) { game.add_lag mob, NUKE_LAG if use_ability( game, mob, rest, ->defender{nuke game, mob, defender}, NUKE_COST) }
end
