
require 'fiber'
require 'bundler'
Bundler.setup
require "active_record"
ActiveRecord::IdentityMap.enabled = true
require "yaml"

ActiveRecord::Base.establish_connection YAML.load_file('config/database.yml')[ ENV['RAILS_ENV'] ]

require "abbrev_map.rb"

require "models/account.rb"
require "models/character.rb"
require "models/mob.rb"
require "models/exit.rb"
require "models/room.rb"

require "util.rb"
require "log.rb"
require "physical_state/base.rb"

Log::get ENV['RAILS_ENV'], { :default => true, :level => Logger::DEBUG }
Log::info "============================== booting ==============================", "mud"

TICK_DURATION = 0.25 # in seconds

Log::info RUBY_VERSION, "ruby version"
Log::info "#{TICK_DURATION.to_s}s", "tick duration"

require "pov.rb"
require "network.rb"
require "account_system.rb"
require "character_system.rb"
require "mob_commands.rb"
require "signal.rb"
require "timer.rb"
require "game/base.rb"

def start_mud
  Log::info "instantiating core components", "mud"
  
  network = Network.new
  auth = Authentication.new network
  account_system = AccountSystem.new network, auth
  character_selection = CharacterSelection.new account_system
  character_system = CharacterSystem.new account_system, character_selection
  game = Game.new character_system

  Log::info "starting tick loop", "mud"
  
  begin
    while true
      tick_start = Time.now
      Log::info "start tick", "mud"
      network.tick
      account_system.tick
      character_system.tick
      game.tick
      tick_duration = Time.now - tick_start
      time_remaining = [0,TICK_DURATION - tick_duration].max
      Log::info "end tick, duration #{"%4.6f" % tick_duration}s, #{"%4.6f" % (tick_duration / TICK_DURATION * 100)}% capacity, sleeping #{"%4.6f" % time_remaining}s", "mud"
      sleep time_remaining
    end
  rescue Exception => e
    Log::fatal "uncaught exception #{e.class}", "mud"
    Log::fatal e.backtrace.join "\t"
    Log::fatal e.message if e.message.length > 0 
  end
end

