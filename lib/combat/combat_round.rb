
module Combat
  class CombatRound
    def initialize
      @engaged = {}
      @round_schedule_depq = Depq.new( ->a,b{
                                         x = nil
                                         if a.start_time == b.start_time
                                           x = 0
                                         elsif a.start_time > b.start_time
                                           x = 1
                                         else
                                           x = -1
                                         end
                                         x })
    end

    def aggress( attacker, defender )
      raise "expected attacker to be a Mob" unless attacker.kind_of? Mob
      raise "expected defender to be a Mob" unless defender.kind_of? Mob
      raise "expected attacker to differ from defender" if attacker == defender
      Log::debug "attacker #{attacker.short_name} aggressed defender #{defender.short_name}", "combatround"
      engage attacker, defender unless engaged? attacker
      nil
    end

    def target_of( mob )
      raise "expected mob to be a Mob" unless mob.kind_of? Mob
      return nil unless engaged? mob
      @engaged[mob].value.defender
    end

    def engaged?( mob )
      raise "expected mob to be a Mob" unless mob.kind_of? Mob
      @engaged.key? mob
    end

    def still_need_to_attack?( attacker )
      raise "expected attacker to be a Mob" unless attacker.kind_of? Mob
      raise "expected attacker to be engaged" unless engaged? attacker
      @engaged[attacker].in_queue?
    end

    def next_round(&block)
      Log::debug "next round", "combatround"
      raise "expected block(attacker,defender)" unless block_given?
      create_schedule
      run_schedule { |attacker,defender| block.call attacker, defender }
      nil
    end


    def valid_attack?( attacker )
      raise "expected attacker to be a Mob" unless attacker.kind_of? Mob
      return false unless engaged? attacker
      target = target_of(attacker)
      return false unless target
      raise "expected target to be a Mob" unless target.kind_of? Mob
      return false unless engaged? target
      return false unless attacker.room == target.room
      true
    end

    def disengage( mob )
      # this mob won't have a valid_attack until it is re-aggressed
      raise "expected mob to be a Mob" unless mob.kind_of? Mob
      raise "expected mob to be engaged" unless engaged? mob
      @engaged.delete mob
      nil
    end
    
    def engage( attacker, defender )
      raise "expected attacker to be a Mob" unless attacker.kind_of? Mob
      raise "expected defender to be a Mob" unless defender.kind_of? Mob
      raise "expected attacker to differ from defender" if attacker == defender
      Log::debug "attacker #{attacker.short_name} engaged defender #{defender.short_name}", "combatround"
      @engaged[ attacker ] = Depq::Locator.new OpenStruct.new({start_time:Time.now, attacker:attacker, defender:defender})
      engage defender, attacker unless engaged? defender
      nil
    end

    private
    def create_schedule
      @round_schedule_depq.clear
      @engaged.each_value { |val| @round_schedule_depq.insert_locator val }
      nil
    end

    def run_schedule(&block)
      return nil unless block_given?
      while val = @round_schedule_depq.delete_min
        puts "val #{val.attacker}"
        next unless valid_attack? val.attacker
        puts "yielding"
        yield val.attacker, target_of(val.attacker)
      end
      nil
    end

  end # class Combat
end
