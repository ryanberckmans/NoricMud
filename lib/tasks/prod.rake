#!/usr/bin/env ruby

namespace :mud do

  desc "stop, gitpull, start"
  task deploy:[:stop, :gitpull, :start]

  desc "git pull"
  task :gitpull do
    puts `ssh mud@noric.org 'cd mud; git pull origin ; cd ../mud-client ; git pull origin'`
  end

  desc "start"
  task :start do
    system "ssh -f mud@noric.org 'source ~/.bash_profile; cd mud/bin; export RAILS_ENV=development; ./mud'"
    system "ssh -f mud@noric.org 'cd mud-client/wm_server ; php5 server.php > /dev/null 2>&1'"
  end

  desc "stop"
  task :stop do
    `ssh mud@noric.org 'ps -C ruby -f | grep mud | sed "s/ \\{1,\\}/ /g" | cut -d" " -f2 | xargs kill -9 2> /dev/null'`
    `ssh mud@noric.org 'ps -C php5 -f | grep server | sed "s/ \\{1,\\}/ /g" | cut -d" " -f2 | xargs kill -9 2> /dev/null'`
  end

  desc "stop then start"
  task bounce:[:stop, :start]

  desc "show log"
  task :log do
    exec "ssh mud@noric.org 'cd mud/log ; tail -f development.log'"
  end

  desc "spawn bots"
  task :bot, :bots do |t, args|
    args.bot(:bots => 5)
    system "ssh -f mud@noric.org 'source ~/.bash_profile ; cd mud/lib ; ruby bot.rb #{args[:bots]}'"
  end
end
