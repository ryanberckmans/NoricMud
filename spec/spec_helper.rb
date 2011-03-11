
ENV['RAILS_ENV'] = "test"

require "mud.rb"

$test_port = Random.new.rand 10000..50000
