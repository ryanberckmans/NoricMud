
module Combat
  class CombatRound
    def initialize
      @engaged = {}
    end

    def aggress( attacker, defender )
      raise "expected attacker to be a Mob" unless attacker.kind_of? Mob
      raise "expected defender to be a Mob" unless defender.kind_of? Mob
      raise "expected attacker to differ from defender" if attacker == defender
      Log::debug "attacker #{attacker.short_name} aggressed defender #{defender.short_name}", "combatround"
      engage attacker, defender unless engaged? attacker
      engage defender, attacker unless engaged? defender
      nil
    end

    def target_of( mob )
      raise "expected mob to be a Mob" unless mob.kind_of? Mob
      @engaged[mob]
    end

    def engaged?( mob )
      raise "expected mob to be a Mob" unless mob.kind_of? Mob
      @engaged.key? mob
    end

    private
    def engage( attacker, defender )
      raise "expected attacker to be a Mob" unless attacker.kind_of? Mob
      raise "expected defender to be a Mob" unless defender.kind_of? Mob
      raise "expected attacker to differ from defender" if attacker == defender
      Log::debug "attacker #{attacker.short_name} engaged defender #{defender.short_name}", "combatround"
      @engaged[ attacker ] = defender
    end

    def disengage( mob )
      
    end
  end
end
