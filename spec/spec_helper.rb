require 'fiber'
require 'bundler'
Bundler.setup
require "active_record"
require "yaml"

ActiveRecord::Base.establish_connection YAML.load_file('config/database.yml')[ ENV['RAILS_ENV'] ]

require "models/exit.rb"
require "models/account.rb"
require "models/character.rb"
require "models/mob.rb"
require "models/room.rb"

require "util.rb"
require "log.rb"

Log::get "spec", { :default => true, :level => Logger::DEBUG }
Log::info "============================== booting ==============================", "mud"

TICK_DURATION = 0.25 # in seconds

Log::info RUBY_VERSION, "ruby version"
Log::info "#{TICK_DURATION.to_s}s", "tick duration"

require "pov.rb"
require "abbrev_map.rb"
require "command_handler.rb"
require "mob_commands.rb"
require "network.rb"
require "account_system.rb"
require "character_system.rb"
require "game/base.rb"

$test_port = Random.new.rand 10000..50000
