files = Dir.glob Util.here "*.rb"
files.each do |f| require f end

module Abilities
  @abilities = AbbrevMap.new
  
  def self.add_ability( cmd, callback )
    @abilities.add cmd, callback
  end

  def self.attempt_energy_use( game, mob, energy )
    if mob.energy < energy
      game.send_msg mob, "{@You can't summon enough energy.\n"
      false
    else
      mob.energy -= energy
      pov_scope do
        pov(mob) { "{!{FWYou invoke the magic and are drained of #{energy} energy.\n" }
        pov(mob.room.mobs) { "{!{FW#{mob.short_name} invokes magic and is drained of energy.\n" }
      end
      true
    end
  end

  def self.cast( game, mob, rest )
    if rest.empty?
      game.send_msg mob, "{@Cast what spell?\n"
      return
    end
    ability = @abilities.find rest
    if ability
      ability[:value].call game, mob, ability[:rest]
    else
      game.send_msg mob, "{@You cannot cast this unknown spell.\n"
    end
  end

  private
  def self.ability_damage( game, attacker, defender, damage )
    damage = (damage * 1.5).to_i if defender.state == PhysicalState::Resting
    damage = (damage * 3).to_i if defender.state == PhysicalState::Meditating
    Combat.damage game, attacker, defender, damage
  end
  
  def self.use_ability( game, attacker, target, ability, ability_name, energy_cost, cooldown, lag, channel )
    raise "expected attacker to be a Mob" unless attacker.kind_of? Mob
    raise "expected target to be a String" unless target.kind_of? String
    raise "expected ability to be a Proc" unless ability.kind_of? Proc
    raise "expected ability_name to be a String" unless ability_name.kind_of? String
    if game.in_cooldown? attacker, ability_name
      game.send_msg attacker, "{@That ability is currently cooling down!\n"
      return nil
    end

    if channel > 0
      game.channel attacker, ->{ use_ability game, attacker, target, ability, ability_name, energy_cost, cooldown, lag, 0 }, channel
      return nil
    end
    
    target_mob = nil
    if target.empty? and game.combat.engaged? attacker
      target_mob = game.combat.target_of attacker
    elsif target.empty?
      game.send_msg attacker, "{@Upon who?\n"
      return nil
    else
      if target =~ /^me$/i
        target_mob = attacker
      else
        attacker.room.mobs.each do |mob_in_room|
          if mob_in_room.short_name =~ Regexp.new( "^#{target}", Regexp::IGNORECASE)
            target_mob = mob_in_room
            break
          end
        end
      end # end if target == me
    end

    return nil unless attempt_energy_use game, attacker, energy_cost

    if target_mob
      ability.call game, attacker, target_mob
    else
      game.send_msg attacker, "Nobody here by that name.\n"
    end
    game.add_cooldown attacker, ability_name, cooldown, ->{ game.send_msg attacker, "#{ability_name.capitalize} has finished cooling down.\n" }
    game.add_lag attacker, lag
    true
  end

  add_ability "nuke", ->(game, mob, rest ) { use_ability( game, mob, rest, NUKE, "nuke", NUKE_COST, NUKE_COOLDOWN, NUKE_LAG, NUKE_CHANNEL) }
  add_ability "heal", ->(game, mob, rest ) { use_ability( game, mob, rest, HEAL, "heal", HEAL_COST, HEAL_COOLDOWN, HEAL_LAG, HEAL_CHANNEL) }
  add_ability "stun", ->(game, mob, rest ) { use_ability( game, mob, rest, STUN, "stun", STUN_COST, STUN_COOLDOWN, STUN_LAG, STUN_CHANNEL) }
  add_ability "burst", ->(game, mob, rest ) { use_ability( game, mob, rest, BURST, "burst", BURST_COST, BURST_COOLDOWN, BURST_LAG, BURST_CHANNEL) }
  add_ability "pitter", ->(game, mob, rest ) { use_ability( game, mob, rest, PITTER, "pitter", PITTER_COST, PITTER_COOLDOWN, PITTER_LAG, PITTER_CHANNEL) }
end
