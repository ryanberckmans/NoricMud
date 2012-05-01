
require 'fiber'
require 'bundler'
Bundler.setup
require "active_record"
ActiveRecord::IdentityMap.enabled = true
require "yaml"

ActiveRecord::Base.establish_connection YAML.load_file('config/database.yml')[ ENV['RAILS_ENV'] ]

require "abbrev_map.rb"

require "account.rb"
require "character.rb"
require "exit.rb"
require "mob.rb"
require "room.rb"
require "noric_mud"

require "util.rb"
require "log.rb"

LOG_LEVEL = Logger::DEBUG
TICK_DURATION = 0.25 # in seconds

Log::get ENV['RAILS_ENV'], { :default => true, :level => LOG_LEVEL }
Log::info "============================== booting ==============================", "mud"

Log::fatal LOG_LEVEL, "log level"
Log::info RUBY_VERSION, "ruby version"
Log::info "#{TICK_DURATION.to_s}s", "tick duration"

require "pov.rb"
require "network.rb"
require "account_system.rb"
require "character_system.rb"
require "mob_commands.rb"
require "game/base.rb"

def start_mud
  Signal.trap :INT do # default JRuby behavior is for the JVM to halt on a SIG_INT; do this instead
    Thread.main.raise Interrupt
  end 

  Log::log_thread_start
  Log::info "instantiating core components", "mud"
  
  network = Network.new
  auth = Authentication.new network
  account_system = AccountSystem.new network, auth
  character_selection = CharacterSelection.new account_system
  character_system = CharacterSystem.new account_system, character_selection
  game = Game.new character_system

  Log::info "starting tick loop", "mud"
  
  begin
    tick_number = 0
    while true
      tick_start = Time.now
      Log::info "start tick #{tick_number}", "mud"
      network.tick
      account_system.tick
      character_system.tick
      game.tick
      tick_duration = Time.now - tick_start
      time_remaining = [0,TICK_DURATION - tick_duration].max
      Log::info "#{tick_number},duration,#{"%4.6f" % tick_duration},capacity%,#{"%4.6f" % (tick_duration / TICK_DURATION * 100)},sleeping,#{"%4.6f" % time_remaining}", "metrics.tick"
      Log::info "end tick #{tick_number}", "mud"
      sleep time_remaining
      tick_number += 1
    end
  rescue Exception => e
    Util::log_exception Logger::FATAL, e, "mud"
    Log::shutdown
  end
end
