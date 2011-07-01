
class ChaosQuest
  LEVEL_RANGE = 1..10
  START_LEVEL = 5

  def initialize( game )
    @game = game
    @fights = []
    @level = {}
    @waiting_to_fight = {}
    @starts_pending = []
    @game.timer.add_periodic 1, ->{ end_fights }
    @game.timer.add_periodic 4, ->{ start_next_fight }
    @game.timer.add_periodic 80, ->{ start_fights }
    @game.bind(:logout) { |e| remove e.target.mob }
    @game.bind(:login) { |e| enroll e.target.mob }
  end

  def remove( mob )
    @level.delete mob
    sanity = 0
    @waiting_to_fight.each_value do |arr|
      if arr.delete mob
        sanity += 1
      end
    end
    raise "expected to find mob at most once" if sanity > 1
    Log::debug "removed #{mob.short_name}", "chaosquest"
  end

  def enroll( mob )
    @level[mob] ||= START_LEVEL
    wait_to_fight mob
    quest_private_msg mob, "{!{FCYou are now enrolled in the {FYe{FRt{FYe{FGr{FRn{FGa{FYl{FC quest! Prepare to face your opponent"
    Log::info "mob #{mob.short_name} enrolled", "chaosquest"
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
        delay = 30
        duel = PitDuel.new(@game, x,y )
        @fights << duel
        proc = ->d{
          ->{ @starts_pending << d }
        }
        @game.timer.add delay*4, proc.call(duel)
        delay_msg = ->original_delay,remain,w,v{
          @game.timer.add (original_delay-remain)*4, ->{
            quest_private_msg v, "In #{remain} seconds you will fight {!{FC#{w.short_name}"
            quest_private_msg w, "In #{remain} seconds you will fight {!{FC#{v.short_name}"
          }
        }
        quest_private_msg x, "In #{delay} seconds you will fight {!{FC#{y.short_name}"
        quest_private_msg y, "In #{delay} seconds you will fight {!{FC#{x.short_name}"
        delay_msg.call(delay,10,x,y)
      end # end while
      if arr.size > 0
        mob = arr.pop
        Log::debug "normalizing #{mob.short_name} level due to level inactivity", "chaosquest"
        if @level[mob] < 5
          quest_private_msg mob, "Rising up a level due to inactivity"
          promote mob
        elsif @level[mob] > 5
          quest_private_msg mob, "Sinking down a level due to inactivity"
          demote mob
        else
        end
        wait_to_fight mob
      end
    end
  end

  def end_fights
    Log::debug "checking for finished fights", "chaosquest"
    @fights.delete_if do |fight|
      finished = fight.finished?
      if fight.finished?
        quest_msg "{!{FC#{fight.winner.short_name} {FWdefeats {FC#{fight.loser.short_name}! {FM[{FCLevel #{@level[fight.winner]}{FM]"
        promote fight.winner
        wait_to_fight fight.winner
        demote fight.loser
        wait_to_fight fight.loser
        true
      else
        false
      end
    end
    Log::debug "done checking for finished fights", "chaosquest"
  end

  private
  def start_next_fight
    duel = @starts_pending.shift
    return unless duel
    x = duel.mob_x
    y = duel.mob_y
    Log::debug "starting duel between #{x.short_name} and #{y.short_name}", "chaosquest"
    duel.start
    quest_msg "{!{FC#{x.short_name} {FWvs {FC#{y.short_name}{FW, {FM[{FCLevel #{@level[x]}{FM]"
  end
  
  def quest_msg( msg )
    Log::debug color(msg+"{@"), "chaosquest"
    msg = "{!{FM[{FYQUEST{FM] {@#{msg}{@\n"
    @game.all_connected_characters.each { |char| @game.send_msg char, msg }
  end

  def quest_private_msg( mob, msg )
    prefix = "{!{FM[{FYQUEST{FM] {FWprivate {@- "
    suffix = " {!{FM[{FCLevel #{@level[mob]}{FM]\n"
    @game.send_msg mob, prefix + msg + suffix
  end

  def wait_to_fight( mob )
    @waiting_to_fight[@level[mob]] ||= []
    if @waiting_to_fight[@level[mob]].index mob
      Log::warn "mob #{mob.short_name} was already waiting to fight, aborted", "chaosquest"
      return
    end
    @waiting_to_fight[@level[mob]] << mob
    Log::info "mob #{mob.short_name} is waiting to fight", "chaosquest"
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
