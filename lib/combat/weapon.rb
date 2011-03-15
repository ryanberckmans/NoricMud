
module Combat
  class Weapon
    WEAPON = {
      dagger:0,
      sword:1,
      axe:2,
    }

    ATTACK_SPEED = {
      # continuous attacks per combat round
      dagger:2.0,
      sword:1.0,
      axe:0.6,
    }

    DAMAGE_TYPE = {
      dagger:"pierce",
      sword:"slash",
      axe:"slice",
    }

    DAMAGE_DICE = {
      dagger:[4,2],
      sword:[4,4],
      axe:[3,9],
    }

    PROC = {
      dagger:->(game,attacker,defender){
        pov_scope do
          pov(attacker) { "{!{FCBlue lightning forks from your dagger, striking #{defender.short_name}.\n" }
          pov(defender) { "{!{FCBlue lightning forks from #{attacker.short_name}'s dagger, striking you.\n"}
          pov(attacker.room.mobs) { "{!{FCBlue lightning forks from #{attacker.short_name}'s dagger, striking #{defender.short_name}.\n"}
        end
        damage = game.combat.weapon.roll_damage attacker
        damage
      },
      sword:->(game,attacker,defender){
        pov_scope do
          pov(attacker) { "{!{FRLiquid fire erupts from your sword, searing #{defender.short_name}.\n" }
          pov(defender) { "{!{FRLiquid fire erupts from #{attacker.short_name}'s sword, searing you.\n"}
          pov(attacker.room.mobs) { "{!{FRLiquid fire erupts from #{attacker.short_name}'s sword, searing #{defender.short_name}.\n"}
        end
        damage = game.combat.weapon.roll_damage attacker
        damage
      },
      axe:->(game,attacker,defender){
        pov_scope do
          pov(attacker) { "{!{FBMenacing black energy crackles forth from your axe and coils around #{defender.short_name}.\n" }
          pov(defender) { "{!{FBMenacing black energy crackles forth from #{attacker.short_name}'s axe and coils around you.\n" }
          pov(attacker.room.mobs) { "{!{FBMenacing black energy crackles forth from #{attacker.short_name}'s axe and coils around #{defender.short_name}\n" }
        end
        damage = game.combat.weapon.roll_damage attacker
        damage
      },
    }

    CRITICAL_CHANCE = {
      # cumulative chance in 1000
      critical:900,
      mega_critical:966,
    }

    CRITICAL = {
      critical:2.0,
      mega_critical:4.0,
    }

    CRITICAL_TEXT = {
      critical:"{!{FRsuperbly",
      mega_critical:"{!{FRCRITICALLY",
    }

    def initialize( game )
      @game = game
      @weapons = {}
    end

    def default_weapon( mob )
      raise "expected mob to be a Mob" unless mob.kind_of? Mob
      @weapons[mob] ||= :dagger
    end

    def melee_attack( attacker, defender )
      Random.new.rand(0..2) < 1 ? melee_miss( attacker, defender) : melee_hit( attacker, defender)
    end
    
    def melee_miss( attacker, defender )
      Log::debug "#{attacker.short_name} melee missed #{defender.short_name}", "combat"
      type = damage_type attacker
      pov_scope do
        pov(attacker) { "{!{FGYour #{type} {FYmisses{FG #{defender.short_name}.\n" }
        pov(defender) { "{!{FY#{attacker.short_name}'s #{type} misses you.\n" }
        # pov(attacker.room.mobs) { "{!{FG#{attacker.short_name}'s #{type} misses #{defender.short_name}.\n" }
      end
      Combat::damage @game, attacker, defender, 0
    end
    
    def melee_hit( attacker, defender )
      raise "expected attacker to be a mob" unless attacker.kind_of? Mob
      raise "expected defender to be a mob" unless defender.kind_of? Mob
      Log::debug "#{attacker.short_name} melee hit #{defender.short_name}", "weapons"
      type = damage_type attacker
      chance = Random.new.rand(1..1000)
      crit = nil
      CRITICAL_CHANCE.each_pair do |crit_type,crit_chance|
        crit = crit_type if chance > crit_chance
      end
      crit_mult = nil
      crit_mult = CRITICAL[crit] if crit
      damage = roll_damage attacker, crit_mult
      damage_text = Combat.damage_text damage
      damage_color = Combat.damage_color damage

      damage_percent_text = Combat.damage_percent_text(damage * 100.0 /  defender.hp)
      if damage_percent_text
        damage_text = damage_percent_text 
        damage_color = "{!{FR"
      end
      if crit
        pov_scope do
          pov(attacker) do "{!{FRYou #{CRITICAL_TEXT[crit]} hit #{defender.short_name}!\n" end
          pov(defender) do "{!{FR#{attacker.short_name} #{CRITICAL_TEXT[crit]} hits you!\n" end
          pov(attacker.room.mobs) do "{!{FR#{attacker.short_name} #{CRITICAL_TEXT[crit]} hits #{defender.short_name}!\n" end
        end
      end
      pov_scope do
        pov(attacker) { "{!{FGYour #{type} #{damage_color}#{damage_text}{FG #{defender.short_name}!\n" }
        pov(defender) { "{!{FY#{attacker.short_name}'s #{type} #{damage_text} you!\n" }
        pov(attacker.room.mobs) { "{!{FG#{attacker.short_name}'s #{type} #{damage_text} #{defender.short_name}!\n" }
      end
      damage += proc( attacker, defender )
      Log::debug "#{attacker.short_name} did #{damage} total damage from melee hit", "weapons"
      Combat::damage @game, attacker, defender, damage
    end

    def attack_speed( mob )
      default_weapon mob
      ATTACK_SPEED[@weapons[mob]]
    end

    def damage_type( mob )
      default_weapon mob
      DAMAGE_TYPE[@weapons[mob]]
    end

    def roll_damage( mob, critical_multiplier=nil )
      default_weapon mob
      critical_multiplier ||= 1.0
      dice = DAMAGE_DICE[@weapons[mob]]
      damage = 0
      dice[0].times do
        damage += Random.new.rand(1..dice[1])
      end
      damage *= critical_multiplier
      Log::debug "mob #{mob.short_name} rolled damage #{damage} with weapon #{@weapons[mob].to_s}, crit multiplier #{critical_multiplier}", "weapon"
      damage.to_i
    end

    def proc( attacker, defender )
      default_weapon attacker
      damage = 0
      damage = PROC[@weapons[attacker]].(@game, attacker, defender) if Random.new.rand(1..10) > 8
      damage
    end

    def weapon_cycle( mob )
      default_weapon mob
      Log::debug "mob #{mob.short_name} cycling weapon, initial weapon #{@weapons[mob].to_s}", "weapon"
      if @weapons[mob] == :axe
        @weapons[mob] = :dagger
      elsif @weapons[mob] == :sword
        @weapons[mob] = :axe
      else
        @weapons[mob] = :sword
      end
      @game.send_msg mob, "Your weapon: {!{FG#{@weapons[mob].to_s}\n"
    end
  end # class Weapon
end
