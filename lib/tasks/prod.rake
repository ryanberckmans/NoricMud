#!/usr/bin/env ruby

namespace :mud do

  task :metrics do
    puts `ssh mud@noric.org 'source ~/.bash_profile; cd mud/bin; env RAILS_ENV=development ./metrics'`
  end

  namespace :branch do
    namespace :mud do
      def switch( branch="master")
        puts `ssh mud@noric.org 'cd mud; git checkout #{branch}'`
      end
      desc "switch to master"
      task :master do
        switch
      end
      desc "switch to profile"
      task :profile do
        switch "profile"
      end
    end
    namespace :client do
    end
  end

  desc "stop, gitpull, start"
  task deploy:[:stop, :gitpull, :start]

  desc "alias for deploy"
  task update:[:deploy]

  desc "git pull"
  task :gitpull do
    puts `ssh mud@noric.org 'source ~/.bash_profile; cd mud; git pull origin ; bundle install --local ; cd ../mud-client ; git pull origin'`
  end

  namespace :start do
    desc "start mud"
    task :mud do
      system "ssh -f mud@noric.org 'source ~/.bash_profile; cd mud/bin; export RAILS_ENV=development; ./mud'"
    end

    desc "start client"
    task :client do
      system "ssh -f mud@noric.org 'cd mud-client/wm_server ; env HOST=`resolveip -s noric.org` php5 server.php > /dev/null 2>&1'"
    end
  end
  desc "start"
  task :start => ["start:mud", "start:client"]

  namespace :stop do
    desc "stop mud"
    task :mud do
      `ssh mud@noric.org 'ps -C ruby -f | grep mud | sed "s/ \\{1,\\}/ /g" | cut -d" " -f2 | xargs kill -9 2> /dev/null'`
    end

    desc "stop client"
    task :client do
      `ssh mud@noric.org 'ps -C php5 -f | grep server | sed "s/ \\{1,\\}/ /g" | cut -d" " -f2 | xargs kill -9 2> /dev/null'`
    end
  end
  desc "stop"
  task :stop => ["stop:mud", "stop:client"]

  desc "stop then start"
  task bounce:[:stop, :start]

  desc "show log"
  task :log do
    exec "ssh mud@noric.org 'cd mud/log ; tail -f development.log'"
  end

  desc "spawn bots"
  task :bot, :bots do |t, args|
    system "ssh -f mud@noric.org 'source ~/.bash_profile ; cd mud/lib ; ruby bot.rb #{args[:bots]}'"
  end
end
