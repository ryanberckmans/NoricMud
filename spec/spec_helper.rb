require 'fiber'
require 'bundler'
Bundler.setup
require "active_record"
require "yaml"

ActiveRecord::Base.establish_connection YAML.load_file('config/database.yml')[ ENV['RAILS_ENV'] ]

require "models/account.rb"
require "models/character.rb"
require "models/mob.rb"
require "models/room.rb"

require "core/util.rb"
require "core/log.rb"

Log::get "spec", { :default => true, :level => Logger::DEBUG }
Log::info "============================== booting ==============================", "mud"

TICK_DURATION = 0.25 # in seconds

Log::info RUBY_VERSION, "ruby version"
Log::info "#{TICK_DURATION.to_s}s", "tick duration"

require "network/base.rb"
require "account-system/base.rb"
require "character-login-system/base.rb"
require "game/base.rb"

$test_port = Random.new.rand 10000..50000
