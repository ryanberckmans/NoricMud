class Channel
  def initialize( game )
    @game = game
    @channel = {}
    @ability = {}
  end

  def channeling?( mob )
    default_channel mob
    @channel[mob] > 0
  end

  def cancel_channel( mob )
    default_channel mob
    if channeling? mob
      @channel[mob] = 0
      @ability.delete mob
      pov_scope do
        pov(mob) { "{!{FCYour channeling has been {FRinterrupted{FC!\n" }
        pov(mob.room.mobs) { "{!{FC#{mob.short_name}'s channeling is {FRinterrupted{FC!\n" }
      end
      Log::debug "#{mob.short_name} cancelled channeling", "channel"
    end
  end
  
  def channel( mob, ability, channel_duration ) # channel_duration in pulses
    raise unless channel_duration.kind_of? Fixnum
    default_channel mob
    raise "expected mob not to be channeling" if @channel[mob] > 0
    pov_scope do
      pov(mob) { "{!{FCYou begin channeling!\n" }
      pov(mob.room.mobs) { "{!{FCThe air crackles as #{mob.short_name} begins channeling!\n"}
    end
    @channel[mob] += channel_duration
    @ability[mob] = ability
    PhysicalState::transition @game, mob, PhysicalState::Channeling
    nil
  end

  def tick
    Log::debug "start tick", "channel"
    @channel.each_key do |mob|
      if @channel[mob] > 0
        @channel[mob] -= 1
        Log::debug "mob #{mob.short_name} has channel #{@channel[mob]}", "channel"
        if @channel[mob] < 1
          Log::debug "mob #{mob.short_name} finished channeling, executing ability", "channel"
          pov_scope do
            pov(mob) { "{!{FCYou finish channeling!\n" }
            pov(mob.room.mobs) { "{!{FC#{mob.short_name} finishes channeling!\n"}
          end
          PhysicalState::transition @game, mob, PhysicalState::Standing
          @ability[mob].call
          @ability.delete mob
        elsif @channel[mob] % 8 == 0
          pov_scope do
            pov(mob) { "{!{FCYou continue to channel!\n" }
            pov(mob.room.mobs) { "{!{FC#{mob.short_name} continues to channel energy!\n"}
          end
        end
      end # if channel[mob] > 0
    end # @channel.each_key
    Log::debug "end tick", "channel"
  end

  private  
  def default_channel( mob )
    raise "expected mob to be a Mob" unless mob.kind_of? Mob
    @channel[mob] ||= 0
  end
end # class Channel
