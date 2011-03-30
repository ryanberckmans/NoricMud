
class ChaosQuest
  LEVEL_RANGE = 1..10
  START_LEVEL = 5

  def initialize( game )
    @game = game
    @fights = []
    @level = {}
    @waiting_to_fight = {}
    start_time = Time.now
    @game.signal.connect :after_tick, ->{ end_fights; false }
    @game.signal.connect :after_tick, ->{
      if Time.now > start_time + 15
        start_time = Time.now
        start_fights
      else
      end
      false
    }
  end

  def enroll( mob )
    @level[mob] ||= START_LEVEL
    @waiting_to_fight[@level[mob]] ||= []
    if @waiting_to_fight[@level[mob]].index mob
      Log::warn "mob #{mob.short_name} was already enrolled, enroll aborted", "chaosquest"
      return
    end
    @waiting_to_fight[@level[mob]] << mob
    # quest_msg "{!{FC#{mob.short_name} {FWis prepared for a fight! {FM[{FCLevel #{@level[mob]}{FM]"
    Log::info "mob #{mob.short_name} enrolled and is waiting to fight", "chaosquest"
  end

  def start_fights
    Log::info "starting fights", "chaosquest"
    @waiting_to_fight.each_key do |level|
      arr = @waiting_to_fight[level]
      arr.shuffle!
      while arr.size > 1
        x = arr.pop
        y = arr.pop
        Log::debug "creating duel between #{x.short_name} and #{y.short_name}", "chaosquest"
        delay = 10
        duel = PitDuel.new(@game, x,y )
        @fights << duel
        msg = "{!{FM[{FYQUEST{FM] {FWprivate {@- In #{delay} seconds you will fight {!{FC"
        @game.send_msg x, msg + y.short_name + " {FM[{FCLevel #{@level[x]}{FM]\n"
        @game.send_msg y, msg + x.short_name + " {FM[{FCLevel #{@level[x]}{FM]\n"
        proc = ->time,v,w,d{
          Proc.new {
            next unless Time.now > time + delay
            Log::debug "starting duel between #{v.short_name} and #{w.short_name}", "chaosquest"
            d.start
            quest_msg "{!{FC#{v.short_name} {FWvs {FC#{w.short_name}{FW, {FM[{FCLevel #{level}{FM]"
            true
          }
        }
        @game.signal.connect :after_tick, proc.call(Time.now,x,y,duel)
      end
    end
  end

  def end_fights
    Log::debug "checking for finished fights", "chaosquest"
    @fights.delete_if do |fight|
      finished = fight.finished?
      if fight.finished?
        quest_msg "{!{FC#{fight.winner.short_name} {FWtriumphs over {FC#{fight.loser.short_name}! {FM[{FCLevel #{@level[fight.winner]}{FM]"
        promote fight.winner
        enroll fight.winner
        demote fight.loser
        enroll fight.loser
        true
      else
        false
      end
    end
  end

  private
  def quest_msg( msg )
    Log::debug msg, "chaosquest"
    msg = "{!{FM[{FYQUEST{FM] {@#{msg}{@\n"
    @game.all_connected_characters.each { |char| @game.send_msg char, msg }
  end
  
  def promote( mob )
    @level[mob] += 1
    @level[mob] = LEVEL_RANGE.max if @level[mob] > LEVEL_RANGE.max
  end

  def demote( mob )
    @level[mob] -= 1
    @level[mob] = LEVEL_RANGE.min if @level[mob] < LEVEL_RANGE.min
  end
end
